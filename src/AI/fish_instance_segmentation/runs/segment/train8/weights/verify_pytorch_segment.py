import torch
import numpy as np
import cv2
from ultralytics import YOLO
from scipy.spatial.distance import euclidean

# ✅ 모델 로드
model_path = "/home/yun/fish_length/dataset/runs/segment/train8/weights/best.pt"  # 또는 best.pt
model = YOLO(model_path)
model.eval()

# ✅ Segment에 export 속성 명시
segment_layer = model.model.model[-1]
setattr(segment_layer, "export", False)  # PyTorch 추론용

# ✅ 입력 이미지 로드
image_path = "/home/yun/fish_length/dataset/test/images/-_7_jpg.rf.34e4a0a06fecc18d2ff555f38f9c7ce4.jpg"
image = cv2.imread(image_path)
input_image = cv2.resize(image, (640, 640))
input_rgb = cv2.cvtColor(input_image, cv2.COLOR_BGR2RGB)
input_tensor = input_rgb.astype(np.float32) / 255.0
input_tensor = torch.tensor(input_tensor).permute(2, 0, 1).unsqueeze(0)  # [1, 3, 640, 640]

# ✅ 추론
with torch.no_grad():
    cls_out, mask_out, proto = model.model(input_tensor)
    cls_out = torch.sigmoid(cls_out)

# ✅ 클래스 및 마스크 벡터 추출
scores = cls_out[0].max(dim=1).values.cpu().numpy()
classes = cls_out[0].argmax(dim=1).cpu().numpy()
mask_vectors = mask_out[0].cpu().numpy()

print(f"[DEBUG] 최대 confidence: {scores.max():.4f}")
print(f"[DEBUG] 평균 confidence: {scores.mean():.4f}")
print(f"[DEBUG] proto shape: {proto.shape}")

# ✅ Confidence 필터링
valid = scores > 0.05
if not np.any(valid):
    print("❌ 감지된 객체 없음")
    exit()

# ✅ 가장 신뢰도 높은 객체 선택
top_idx = np.argmax(scores)
mask_vector = mask_vectors[top_idx]
class_id = classes[top_idx]
class_name = ["fish", "cephalopod"][class_id]

# ✅ 마스크 복원
proto_np = proto[0].cpu().permute(1, 2, 0).numpy()  # [H, W, C]
proto_np = proto_np[:, :, :mask_vector.shape[0]]  # 맞춰서 slice
dot_result = np.dot(proto_np.reshape(-1, mask_vector.shape[0]), mask_vector)
scaled_mask = dot_result.reshape(proto_np.shape[:2])
mask_sigmoid = 1 / (1 + np.exp(-scaled_mask))
mask_binary = (mask_sigmoid > 0.3).astype(np.uint8)
mask = cv2.resize(mask_binary, (640, 640), interpolation=cv2.INTER_NEAREST)

# ✅ 윤곽선 추출
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

# ✅ 가장 먼 두 점 계산
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

# ✅ 시각화
vis = input_image.copy()
cv2.drawContours(vis, [largest], -1, (0, 255, 255), 2)
cv2.line(vis, tuple(pt1), tuple(pt2), (0, 255, 0), 2)
cv2.putText(vis, f"{class_name} / {max_dist:.2f}px", (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
cv2.imwrite("verify_pytorch_result.png", vis)
print("📏 길이: {:.2f}px".format(max_dist))
print("💾 시각화 저장 완료: verify_pytorch_result.png")
