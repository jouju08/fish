
import numpy as np
import cv2
import tensorflow as tf
from scipy.spatial.distance import euclidean

# === 모델 로딩 ===
interpreter = tf.lite.Interpreter(model_path="/home/yun/fish_length/dataset/segment_flex.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# === 이미지 로딩 및 전처리 ===
image = cv2.imread("test/images/-_7_jpg.rf.04c2a804af06994fb42e6ba6f3a2ad2d.jpg")  # 분석할 물고기 이미지
input_image = cv2.resize(image, (640, 640))
input_tensor = input_image.astype(np.float32) / 255.0
input_tensor = np.expand_dims(input_tensor, axis=0)

# === 추론 실행 ===
interpreter.set_tensor(input_details[0]['index'], input_tensor)
interpreter.invoke()

# === 출력 텐서 ===
output0 = interpreter.get_tensor(output_details[0]['index'])  # cls+box+mask coef
output1 = interpreter.get_tensor(output_details[1]['index'])  # proto

# === 결과 해석 ===
boxes = output0[0, :, :4]
scores = output0[0, :, 4]
mask_coefs = output0[0, :, 5:]
proto = output1[0]  # (h, w, npr)

# === Top-1 예측 선택 ===
top_idx = np.argmax(scores)
mask_vector = mask_coefs[top_idx]
bbox = boxes[top_idx]

# === 마스크 복원 ===
h, w, _ = proto.shape
mask = np.dot(proto.reshape(-1, proto.shape[2]), mask_vector)
mask = mask.reshape((h, w))
mask = 1 / (1 + np.exp(-mask))  # sigmoid
mask = (mask > 0.5).astype(np.uint8)

# === 윤곽선 추출 ===
contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
if not contours:
    print("윤곽이 없습니다.")
    exit()

largest = max(contours, key=cv2.contourArea)

# === 가장 먼 두 점 계산 ===
max_dist = 0
pt1, pt2 = None, None
for i in range(len(largest)):
    for j in range(i + 1, len(largest)):
        p1 = largest[i][0]
        p2 = largest[j][0]
        dist = euclidean(p1, p2)
        if dist > max_dist:
            max_dist = dist
            pt1, pt2 = p1, p2

print("픽셀 거리:", max_dist)

# === 시각화 ===
vis = cv2.resize(image, (640, 640))
cv2.line(vis, tuple(pt1), tuple(pt2), (0, 255, 0), 2)
cv2.imshow("Fish Length", vis)
cv2.waitKey(0)
cv2.destroyAllWindows()