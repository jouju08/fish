from ultralytics import YOLO
import torch

# 모델 로드
model = YOLO("/home/yun/fish_length/dataset/runs/segment/train8/weights/best.pt")

# ✅ export 모드 설정
model.export = True  # custom attribute for ONNX export logic

# 더미 입력 생성 (배치 1, 3채널, 640x640)
dummy_input = torch.randn(1, 3, 640, 640)

# ONNX로 export (opset 12, dynamic shape OFF, simplify OFF)
torch.onnx.export(
    model.model,              # 내부 PyTorch 모델
    dummy_input,              # 입력 텐서
    "best.onnx",              # 저장 경로
    export_params=True,       # 파라미터 내장
    opset_version=12,         # opset 버전
    do_constant_folding=True, # 상수 폴딩 최적화
    input_names=["images"],   # 입력 노드 이름
    output_names=["output0", "output1"],  # 출력 노드 이름
    dynamic_axes=None         # 정적 shape
)

print("✅ Exported best.onnx with sigmoid manually applied during export.")
