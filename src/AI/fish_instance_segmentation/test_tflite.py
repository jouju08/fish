import numpy as np
import cv2
import tensorflow as tf
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')  # GUI 없는 환경에서 이미지 저장용

# 🔧 경로 설정
tflite_path = "/home/yun/fish_length/dataset/segment_flex.tflite"
image_path = "test/images/-_7_jpg.rf.04c2a804af06994fb42e6ba6f3a2ad2d.jpg"
proto_path = "proto.npy"  # PyTorch에서 저장한 proto

# 🔹 이미지 로딩 및 전처리
img = cv2.imread(image_path)
img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
img_resized = cv2.resize(img_rgb, (640, 640))
input_data = img_resized.transpose(2, 0, 1)[None].astype(np.float32) / 255.0  # (1, 3, 640, 640)

# 🔹 TFLite 모델 로딩
interpreter = tf.lite.Interpreter(model_path=tflite_path)
interpreter.allocate_tensors()

input_index = interpreter.get_input_details()[0]['index']
output_index = interpreter.get_output_details()[0]['index']

interpreter.set_tensor(input_index, input_data)
interpreter.invoke()
output = interpreter.get_tensor(output_index)[0]  # (6400, 34)

# 🔍 logit → sigmoid로 confidence 변환
cls_logit = output[:, 1]
cls_conf = 1 / (1 + np.exp(-cls_logit))  # sigmoid

# 🔍 디버깅용 출력
print("최대 confidence:", np.max(cls_conf))
print("상위 10개 confidence:", np.sort(cls_conf)[-10:])

# 🔍 top-1 무조건 사용
best_idx = np.argmax(cls_conf)
mask_vector = output[best_idx, 2:]  # (32,)

# 🔹 proto 불러오기 및 마스크 복원
proto = np.load(proto_path)              # (32, 160, 160)
proto_flat = proto.reshape(32, -1)       # (32, 25600)
mask_flat = np.dot(mask_vector, proto_flat)  # (25600,)
mask_sigmoid = 1 / (1 + np.exp(-mask_flat))  # sigmoid
mask = mask_sigmoid.reshape(160, 160)        # (160, 160)

# 🔹 후처리 및 시각화
mask_bin = (mask > 0.5).astype(np.uint8) * 255
mask_colored = cv2.applyColorMap(mask_bin, cv2.COLORMAP_JET)
mask_colored = cv2.resize(mask_colored, (img.shape[1], img.shape[0]))
overlay = cv2.addWeighted(img_rgb, 0.8, mask_colored, 0.4, 0)

# 🔹 시각화 저장
plt.figure(figsize=(10, 5))
plt.imshow(overlay)
plt.title("Fish Mask Overlay (TFLite + PyTorch Proto)")
plt.axis("off")
plt.tight_layout()
plt.savefig("fish_mask_overlay.png")
print("✅ 물고기 윤곽 시각화 저장 완료: fish_mask_overlay.png")
