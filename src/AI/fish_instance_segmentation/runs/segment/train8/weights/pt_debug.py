from ultralytics import YOLO
import torch

model = YOLO("/home/yun/fish_length/dataset/runs/segment/train8/weights/best_modified.pt")
segment = model.model.model[-1]

print(segment)
print("Segment 구조 확인:", segment.nm, segment.npr)
print("export 속성:", getattr(segment, 'export', '없음'))
