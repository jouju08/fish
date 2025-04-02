import torch

def load_segment_layer(path):
    raw = torch.load(path, map_location="cpu", weights_only=False)
    model = raw["model"] if isinstance(raw, dict) and "model" in raw else raw
    # model.model이 존재하면 계속 타고 들어가고, 아니면 그 자체가 Sequential일 수 있음
    if hasattr(model, "model") and isinstance(model.model, torch.nn.Sequential):
        return model.model[-1]
    elif isinstance(model, torch.nn.Sequential):
        return model[-1]
    else:
        raise ValueError("Segment layer를 찾을 수 없습니다.")

# 경로
path_original = "/home/yun/fish_length/dataset/runs/segment/train8/weights/best.pt"
path_modified = "/home/yun/fish_length/dataset/runs/segment/train8/weights/best_modified.pt"

# Segment layer 추출
segment_original = load_segment_layer(path_original)
segment_modified = load_segment_layer(path_modified)

# 비교 출력
print("📦 원본 Segment 타입:", type(segment_original))
print("📦 수정본 Segment 타입:", type(segment_modified))

print("🔍 원본 export 속성 있음?", hasattr(segment_original, "export"))
print("🔍 수정본 export 속성 있음?", hasattr(segment_modified, "export"))

print("✅ 원본 export 값:", getattr(segment_original, "export", "❌ 없음"))
print("✅ 수정본 export 값:", getattr(segment_modified, "export", "❌ 없음"))
