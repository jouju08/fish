import onnx
import onnxruntime
import numpy as np

# ✅ 1. ONNX 모델 로드 및 검증
onnx_model_path = "segment_v3.onnx"
model = onnx.load(onnx_model_path)
onnx.checker.check_model(model)
print("✅ ONNX 모델 형식 및 구조 검증 완료")

# ✅ 2. 입력/출력 정보 확인
session = onnxruntime.InferenceSession(onnx_model_path)
input_name = session.get_inputs()[0].name
output_names = [output.name for output in session.get_outputs()]

print(f"📥 입력 이름: {input_name}")
print(f"📤 출력 이름들: {output_names}")

# ✅ 3. 더미 입력으로 추론 테스트
dummy_input = np.random.rand(1, 3, 640, 640).astype(np.float32)
outputs = session.run(output_names, {input_name: dummy_input})

# ✅ 4. 각 output의 shape 출력
for i, out in enumerate(outputs):
    print(f"🔎 Output {i} ({output_names[i]}) shape: {out.shape}")

# ✅ 5. mask_vector shape만 따로 확인
mask_vectors = outputs[1][0]  # output_mask: [1, 6400, 32] → [6400, 32]
print(f"🎯 mask_vector shape: {mask_vectors.shape}")
