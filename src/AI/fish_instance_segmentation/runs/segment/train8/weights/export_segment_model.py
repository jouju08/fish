# import torch
# from ultralytics import YOLO
# import torch.nn.functional as F
# import cv2
# import numpy as np

# # ✅ 1. best_modified.pt 로드
# model = YOLO("/home/yun/fish_length/dataset/runs/segment/train8/weights/best_modified.pt")

# # ✅ 2. export 모드 설정
# model.model.model[-1].export = True
# model.model.eval()
# for m in model.model.modules():
#     m.eval()

# # ✅ 3. 실제 이미지 기반 입력 (더미 말고 실제 사진으로)
# image_path = "/home/yun/fish_length/dataset/test/images/-_7_jpg.rf.34e4a0a06fecc18d2ff555f38f9c7ce4.jpg"
# image = cv2.imread(image_path)
# image = cv2.resize(image, (640, 640))
# image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
# input_tensor = torch.tensor(image).permute(2, 0, 1).unsqueeze(0).float() / 255.0  # [1, 3, 640, 640]

# # ✅ 4. export 모드에서 PyTorch 추론 → confidence 확인
# with torch.no_grad():
#     cls, mask, proto = model.model(input_tensor)
#     print("🔥 PyTorch export mode cls max:", cls.max())
#     print(f"🧪 shape match check → cls: {cls.shape}, mask: {mask.shape}")

# # ✅ 5. ONNX로 export
# torch.onnx.export(
#     model.model,
#     input_tensor,
#     "segment_v3.onnx",
#     opset_version=12,
#     input_names=["images"],
#     output_names=["output_cls", "output_mask", "proto"],
#     dynamic_axes={
#         "images": {0: "batch"},
#         "output_cls": {0: "batch", 1: "anchors"},
#         "output_mask": {0: "batch", 1: "anchors"},
#         "proto": {0: "batch"}
#     }
# )

# print("✅ ONNX export 성공: segment_v3.onnx")
import torch
from ultralytics import YOLO
import torch.nn.functional as F
import cv2
import numpy as np

# ✅ 1. 모델 로드
model = YOLO("/home/yun/fish_length/dataset/runs/segment/train8/weights/best_modified.pt")

# ✅ 2. 이미지 전처리
image_path = "/home/yun/fish_length/dataset/test/images/-_7_jpg.rf.34e4a0a06fecc18d2ff555f38f9c7ce4.jpg"
image = cv2.imread(image_path)
image = cv2.resize(image, (640, 640))
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
input_tensor = torch.tensor(image_rgb).permute(2, 0, 1).unsqueeze(0).float() / 255.0  # [1, 3, 640, 640]

# ✅ 3. export = False에서 confidence 확인
model.model.model[-1].export = False
model.model.eval()
with torch.no_grad():
    cls_orig, _, _ = model.model(input_tensor)
    print("🔁 원래 모델 cls max:", cls_orig.max())

# ✅ 4. export 모드로 전환 및 confidence 확인
model.model.model[-1].export = True
model.model.eval()
for m in model.model.modules():
    m.eval()

with torch.no_grad():
    cls_exp, mask_exp, proto_exp = model.model(input_tensor)
# ✅ 5. ONNX Export
onnx_path = "segment_v3.onnx"
torch.onnx.export(
    model.model,
    input_tensor,
    onnx_path,
    opset_version=12,
    input_names=["images"],
    output_names=["output_cls", "output_mask", "proto"],
    dynamic_axes={
        "images": {0: "batch"},
        "output_cls": {0: "batch", 1: "anchors"},
        "output_mask": {0: "batch", 1: "anchors"},
        "proto": {0: "batch"}
    }
)

print(f"✅ ONNX export 성공: {onnx_path}")
