import onnxruntime
import numpy as np
import cv2
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

# 경로 설정
onnx_path = "/home/yun/fish_length/dataset/runs/segment/train8/weights/segment.onnx"
img_path = "test/images/-_7_jpg.rf.04c2a804af06994fb42e6ba6f3a2ad2d.jpg"

# 이미지 로드 및 전처리
img = cv2.imread(img_path)
img = cv2.resize(img, (640, 640))
img_input = img.transpose(2, 0, 1)[None] / 255.0  # (1, 3, 640, 640)
img_input = img_input.astype(np.float32)

# ONNX 세션 생성
session = onnxruntime.InferenceSession(onnx_path)
input_name = session.get_inputs()[0].name
output = session.run(None, {input_name: img_input})[0]  # (1, 6400, 34)

# 클래스 확률 + 마스크 계수 분리
class_logits = output[0, :, :2]
mask_vectors = output[0, :, 2:]

# softmax -> 클래스 1 confidence heatmap
class_probs = np.exp(class_logits) / np.sum(np.exp(class_logits), axis=1, keepdims=True)
confidence_map = class_probs[:, 1].reshape(80, 80)

# 마스크 벡터 시각화용
mask_channel_0 = mask_vectors[:, 0].reshape(80, 80)

# 통계 출력
print(f"📊 Mask Coeff 평균: {mask_vectors.mean():.4f}, 표준편차: {mask_vectors.std():.4f}")

# 시각화
plt.figure(figsize=(12, 4))
plt.subplot(1, 3, 1)
plt.title("Input Image")
plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
plt.axis("off")

plt.subplot(1, 3, 2)
plt.title("Class Confidence Heatmap")
plt.imshow(confidence_map, cmap="hot")
plt.axis("off")

plt.subplot(1, 3, 3)
plt.title("Mask Coeff Channel 0")
plt.imshow(mask_channel_0, cmap="plasma")
plt.axis("off")

plt.tight_layout()
plt.savefig("onnx_test_result.png")
print("✅ 저장 완료: onnx_test_result.png")
