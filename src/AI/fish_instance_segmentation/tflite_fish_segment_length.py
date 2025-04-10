import numpy as np
import cv2
import tensorflow as tf
from scipy.spatial.distance import euclidean

# ✅ 1. TFLite 모델 로드
interpreter = tf.lite.Interpreter(
    model_path="/home/yun/fish_length/dataset/runs/segment/train8/weights/segment_tf_model/segment_v3_sim_float32.tflite"
)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# ✅ 2. 이미지 불러오기 및 전처리
image_path = "/home/yun/다운로드/fish1.jpg"
image = cv2.imread(image_path)
input_image = cv2.resize(image, (640, 640))
input_image_rgb = cv2.cvtColor(input_image, cv2.COLOR_BGR2RGB)  # ✅ RGB 변환
input_tensor = input_image_rgb.astype(np.float32) / 255.0
input_tensor = np.expand_dims(input_tensor, axis=0)  # NHWC

# ✅ 입력 이미지 저장 (디버깅용)
cv2.imwrite("debug_input_image.png", input_image)

# ✅ 3. TFLite 추론
interpreter.set_tensor(input_details[0]['index'], input_tensor)
interpreter.invoke()

output_cls = interpreter.get_tensor(output_details[0]['index'])[0]   # [6400, 2]
output_mask = interpreter.get_tensor(output_details[1]['index'])[0]  # [6400, 32]
proto = interpreter.get_tensor(output_details[2]['index'])[0]        # [80, 80, 32]

# ✅ 4. Confidence 필터링
conf_threshold = 0.05  # 낮춰서 시도
probs = 1 / (1 + np.exp(-output_cls))  # ✅ sigmoid
scores = np.max(probs, axis=1)
classes = np.argmax(probs, axis=1)

# ✅ confidence 디버깅
print(f"[DEBUG] output_cls shape: {output_cls.shape}")
print(f"[DEBUG] 최대 confidence: {np.max(scores):.4f}")
print(f"[DEBUG] 평균 confidence: {np.mean(scores):.4f}")
print(f"[DEBUG] threshold 이상 점수 개수: {np.sum(scores > conf_threshold)}")

valid = scores > conf_threshold
if not np.any(valid):
    print("❌ 감지된 객체 없음")
    exit()

scores = scores[valid]
classes = classes[valid]
mask_coefs = output_mask[valid]

# ✅ 5. 가장 신뢰도 높은 객체 선택
top_idx = np.argmax(scores)
mask_vector = mask_coefs[top_idx]
class_id = classes[top_idx]
class_name = [ "cephalopod","fish"][class_id]

# ✅ 6. 마스크 복원
print(f"[DEBUG] proto shape (before slicing): {proto.shape}")
print(f"[DEBUG] mask_vector shape: {mask_vector.shape}")
proto = proto[:, :, :mask_vector.shape[0]]
print(f"[DEBUG] proto shape (after slicing): {proto.shape}")

dot_result = np.dot(proto.reshape(-1, mask_vector.shape[0]), mask_vector)
dot_result = dot_result / 2.0
scaled_mask = dot_result.reshape((proto.shape[0], proto.shape[1]))
mask_sigmoid = 1 / (1 + np.exp(-scaled_mask))
mask_binary = (mask_sigmoid > 0.3).astype(np.uint8)

# ✅ 마스크 리사이즈
mask = cv2.resize(mask_binary, (640, 640), interpolation=cv2.INTER_NEAREST)

# ✅ 노이즈 제거
kernel = np.ones((3, 3), np.uint8)
mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=2)
mask = cv2.morphologyEx(mask, cv2.MORPH_DILATE, kernel, iterations=1)

# ✅ 마스크 저장
cv2.imwrite("debug_scaled_sigmoid_mask.png", (mask_sigmoid * 255).astype(np.uint8))
cv2.imwrite("debug_scaled_binary_mask.png", mask * 255)
print("🧪 마스크 이미지 저장 완료")

# ✅ 7. 윤곽선 필터링
contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

filtered = []
for cnt in contours:
    area = cv2.contourArea(cnt)
    x, y, w, h = cv2.boundingRect(cnt)
    if area > 1000 and w > 30 and h > 30:
        filtered.append(cnt)

if not filtered:
    print("❌ 유효한 윤곽선 없음")
    exit()

largest = max(filtered, key=cv2.contourArea)

# ✅ 8. 가장 왼쪽·오른쪽 점 기반 수평 거리 측정
leftmost = tuple(largest[largest[:, :, 0].argmin()][0])
rightmost = tuple(largest[largest[:, :, 0].argmax()][0])

# 수평선의 y좌표: 왼쪽 점 기준
intersect_y = leftmost[1]
intersect_x = rightmost[0]
intersection_point = (intersect_x, intersect_y)

# 유클리드 거리 (왼쪽점 <-> 교차점)
from scipy.spatial.distance import euclidean
length_px = euclidean(leftmost, intersection_point)

# ✅ 9. 시각화 및 출력
print(f"[DEBUG] 왼쪽 점: {leftmost}, 오른쪽 점: {rightmost}, 교차점: {intersection_point}")
print(f"✅ 클래스: {class_name}")
print(f"📏 수평 길이(px): {length_px:.2f}")

vis = input_image.copy()
cv2.drawContours(vis, [largest], -1, (0, 255, 255), 2)

# 수평선 (왼쪽 → 교차점)
cv2.line(vis, leftmost, intersection_point, (0, 255, 0), 2)

# 수직 보조선 (오른쪽 점 → 교차점)
cv2.line(vis, rightmost, intersection_point, (255, 0, 255), 1, lineType=cv2.LINE_AA)  # 보조선은 자주색

# 텍스트 정보
cv2.putText(vis, f"{class_name} / {length_px:.2f}px", (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)

cv2.imwrite("result_horizontal_length_with_helper.png", vis)
print("💾 최종 시각화 이미지 저장 완료: result_horizontal_length_with_helper.png")
