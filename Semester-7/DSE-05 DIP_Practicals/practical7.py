# 7. Noise Models and Restoration.
#     - a. Image restoration.
#     - b. Remove salt and pepper noise.
#     - c. Minimize Gaussian noise.
#     - d. Median filter and Wiener filter.


import cv2
import numpy as np
import os
import random
from scipy.signal import wiener

random.seed(42)
np.random.seed(42)

os.makedirs("result/program7", exist_ok=True)

# Load input image
img = cv2.imread("result/input.png", 0)
if img is None:
    for p in ["input.jpg", "result/program1/input.jpg", "result/program5/grayscale.jpg"]:
        if os.path.exists(p):
            img = cv2.imread(p, 0)
            if img is not None:
                break
if img is None:
    img = np.zeros((256, 256), dtype=np.uint8)
    cv2.rectangle(img, (50, 50), (200, 200), 150, -1)

cv2.imwrite("result/program7/original.jpg", img)

# a. Image restoration - degrade original (blur + noise)
degraded = cv2.GaussianBlur(img, (5, 5), 1.5)
noise = np.random.normal(0, 5, img.shape)
degraded = np.clip(degraded.astype(float) + noise, 0, 255).astype(np.uint8)
cv2.imwrite("result/program7/degraded.jpg", degraded)
restored = wiener(degraded.astype(np.float32), mysize=5, noise=None)
restored = np.clip(restored, 0, 255).astype(np.uint8)
cv2.imwrite("result/program7/restored.jpg", restored)

# b. Add and Remove Salt and pepper noise
sp_noisy = img.copy()
total = img.size
n_s = int(0.05 * total * 0.5)
n_p = int(0.05 * total * 0.5)
for _ in range(n_s):
    r, c = random.randint(0, img.shape[0]-1), random.randint(0, img.shape[1]-1)
    sp_noisy[r, c] = 255
for _ in range(n_p):
    r, c = random.randint(0, img.shape[0]-1), random.randint(0, img.shape[1]-1)
    sp_noisy[r, c] = 0
cv2.imwrite("result/program7/salt_pepper_noisy.jpg", sp_noisy)
sp_removed = cv2.medianBlur(sp_noisy, 3)
cv2.imwrite("result/program7/sp_removed.jpg", sp_removed)

# c. Minimize Gaussian noise
g_noisy = np.clip(img.astype(float) + np.random.normal(0, 10, img.shape), 0, 255).astype(np.uint8)
cv2.imwrite("result/program7/gaussian_noisy.jpg", g_noisy)

# Minimize Gaussian noise using Gaussian blur
g_minimized = cv2.GaussianBlur(g_noisy, (5, 5), 0)
cv2.imwrite("result/program7/gaussian_minimized.jpg", g_minimized)

# d. Median filter  on Salt & Pepper noise
sp_median = cv2.medianBlur(sp_noisy, 3)
cv2.imwrite("result/program7/sp_median.jpg", sp_median)
# d. Wiener filter on Salt & Pepper noise
sp_wiener = np.clip(wiener(sp_noisy.astype(np.float32), mysize=5, noise=None), 0, 255).astype(np.uint8)
cv2.imwrite("result/program7/sp_wiener.jpg", sp_wiener)

print("All outputs saved to result/program7/")