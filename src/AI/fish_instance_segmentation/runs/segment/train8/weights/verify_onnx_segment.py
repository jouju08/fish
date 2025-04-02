import onnx
import onnxruntime
import numpy as np
import torch
import cv2

# ✅ 1. ONNX 모델 로딩 및 검증
model_path = "segment_v3.onnx"  # 혹은 segment_v3.onnx
print(f"📦 모델 경로: {model_path}")
model = onnx.load(model_path)
onnx.checker.check_model(model)
print("✅ ONNX 모델 구조 유효성 검사 통과")

# ✅ 2. ONNX Runtime으로 추론 테스트
session = onnxruntime.InferenceSession(model_path, providers=["CPUExecutionProvider"])
input_name = session.get_inputs()[0].name
print(f"🧠 입력 이름: {input_name}")

# ✅ 3. 실제 이미지 로딩 및 전처리
image_path = "/home/yun/fish_length/dataset/test/images/-_7_jpg.rf.04c2a804af06994fb42e6ba6f3a2ad2d.jpg"
image = cv2.imread(image_path)
image_resized = cv2.resize(image, (640, 640))
image_rgb = cv2.cvtColor(image_resized, cv2.COLOR_BGR2RGB)
input_tensor = image_rgb.astype(np.float32) / 255.0
input_tensor = np.transpose(input_tensor, (2, 0, 1))  # HWC → CHW
input_tensor = np.expand_dims(input_tensor, axis=0)   # [1, 3, 640, 640]

# ✅ 4. ONNX 추론
outputs = session.run(None, {input_name: input_tensor})
output_cls, output_mask, proto = outputs
print(f"✅ output_cls shape: {output_cls.shape}")
print(f"✅ output_mask shape: {output_mask.shape}")
print(f"✅ proto shape: {proto.shape}")

# ✅ 5. Confidence 확인
output_cls_tensor = torch.tensor(output_cls)
probs = output_cls_tensor  # sigmoid 이미 적용됨
max_conf = probs.max().item()
print(f"📊 최대 confidence: {max_conf:.4f}")

# ✅ 6. 마스크 복원 및 시각화
probs_np = probs.numpy()[0]  # [8400, 2]
valid_scores = probs_np[:output_mask.shape[1]]  # [6400, 2]
top_idx = np.argmax(valid_scores.max(axis=1))
print(f"🧪 top_idx={top_idx}, mask_shape={output_mask.shape}")


mask_coef = output_mask[0][top_idx]  # [32]
proto_map = proto[0].transpose(1, 2, 0)  # (80, 80, 32)

dot_result = np.dot(proto_map.reshape(-1, mask_coef.shape[0]), mask_coef)
mask = dot_result.reshape(proto_map.shape[:2])
mask = 1 / (1 + np.exp(-mask))  # sigmoid
mask = (mask > 0.3).astype(np.uint8)
mask = cv2.resize(mask, (640, 640), interpolation=cv2.INTER_NEAREST)

# ✅ 윤곽선 시각화
vis = image_resized.copy()
contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
if contours:
    largest = max(contours, key=cv2.contourArea)
    cv2.drawContours(vis, [largest], -1, (0, 255, 255), 2)

    # 가장 먼 두 점 계산
    max_dist = 0
    pt1, pt2 = None, None
    for i in range(len(largest)):
        for j in range(i + 1, len(largest)):
            p1 = largest[i][0]
            p2 = largest[j][0]
            dist = np.linalg.norm(p1 - p2)
            if dist > max_dist:
                max_dist = dist
                pt1, pt2 = p1, p2

    cv2.line(vis, tuple(pt1), tuple(pt2), (0, 255, 0), 2)
    cv2.putText(vis, f"{max_dist:.2f}px", (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)

    print(f"📏 가장 먼 두 점 거리: {max_dist:.2f}px")
else:
    print("❌ 유효한 윤곽선 없음")

cv2.imwrite("verify_onnx_result.png", vis)
print("📊 max mask_coef:", mask_coef.max())
print("📊 max proto_map:", proto_map.max())
print("📊 max dot_result:", dot_result.max())
print("📊 unique in sigmoid(mask):", np.unique(mask))
print("💾 시각화 결과 저장 완료: verify_onnx_result.png")
