import numpy as np
import cv2
import matplotlib.pyplot as plt
from itertools import combinations
import matplotlib
matplotlib.use('Agg')

# 📁 경로 설정
proto_path = "proto.npy"
mask_vector_path = "mask_vector.npy"
image_path = "test/images/-_7_jpg.rf.04c2a804af06994fb42e6ba6f3a2ad2d.jpg"

# 1. 데이터 로드
proto = np.load(proto_path)  # (32, 160, 160)
mask_vector = np.load(mask_vector_path)  # (32,)
proto = proto.transpose(1, 2, 0)  # (160, 160, 32)

# 2. 이미지 로딩
img = cv2.imread(image_path)
img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

# 3. 마스크 복원
H, W, C = proto.shape
mask_flat = proto.reshape(-1, C) @ mask_vector  # (160*160,)
mask = 1 / (1 + np.exp(-mask_flat))  # sigmoid
mask = mask.reshape(H, W)

# 4. 원본 이미지 크기로 resize + 이진화
mask_resized = cv2.resize(mask, (img.shape[1], img.shape[0]))
_, binary_mask = cv2.threshold(mask_resized, 0.6, 1, cv2.THRESH_BINARY)

# 5. 윤곽선 탐지 및 거리 계산
contours, _ = cv2.findContours((binary_mask * 255).astype(np.uint8),
                               cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
vis_img = img_rgb.copy()
longest_dist = 0
pt1 = pt2 = (0, 0)

if contours:
    cnt = max(contours, key=cv2.contourArea)
    for a, b in combinations(cnt[:, 0], 2):
        d = np.linalg.norm(a - b)
        if d > longest_dist:
            longest_dist = d
            pt1, pt2 = tuple(a), tuple(b)

    cv2.drawContours(vis_img, [cnt], -1, (0, 255, 0), 2)
    cv2.line(vis_img, pt1, pt2, (255, 0, 0), 2)
    cv2.circle(vis_img, pt1, 5, (0, 255, 255), -1)
    cv2.circle(vis_img, pt2, 5, (0, 255, 255), -1)

# 6. 결과 저장
plt.figure(figsize=(10, 6))
plt.imshow(vis_img)
plt.title(f"🐟 Fish Length from PyTorch Proto: {longest_dist:.2f} px")
plt.axis("off")
plt.tight_layout()
plt.savefig("fish_length_from_pytorch_proto.png")

plt.figure(figsize=(6, 6))
plt.imshow(mask_resized, cmap='inferno')
plt.title("🔥 Proto-based Mask Heatmap")
plt.colorbar()
plt.tight_layout()
plt.savefig("mask_heatmap_from_proto.png")
