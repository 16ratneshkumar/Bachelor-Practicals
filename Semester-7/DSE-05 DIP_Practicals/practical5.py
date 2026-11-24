# 5. Histogram Calculation and Equalization.
#     - a. Using inbuilt function.
#     - b. Without using inbuilt function.


import cv2
import numpy as np
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

os.makedirs("result/program5", exist_ok=True)

# Load image
img = cv2.imread("result/input.png")
if img is None:
    for p in ["input.jpg", "result/program1/input.jpg", "result/program5/input_ref.jpg", "result/program7/input_ref.jpg"]:
        img = cv2.imread(p)
        if img is not None:
            break
if img is None:
    img = np.zeros((256, 256, 3), dtype=np.uint8)
    cv2.rectangle(img, (50, 50), (200, 200), (120, 180, 220), -1)

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
cv2.imwrite("result/program5/input_img.jpg", gray)
cv2.imwrite("result/program5/grayscale.jpg", gray)

# a
eq_builtin = cv2.equalizeHist(gray)
cv2.imwrite("result/program5/equalized_builtin.jpg", eq_builtin)

# b
cdf = cv2.calcHist([gray], [0], None, [256], [0, 256]).flatten().cumsum()
cdf_min = cdf[cdf != 0].min() if np.any(cdf != 0) else 0
cdf_max = cdf[-1]
denom = cdf_max - cdf_min
if denom <= 0:
    lut = np.zeros(256, dtype=np.uint8)
else:
    lut = ((cdf - cdf_min) * 255.0 / denom)
    lut = np.clip(lut, 0, 255).astype(np.uint8)
img_eq_manual = lut[gray]
cv2.imwrite("result/program5/equalized_manual.jpg", img_eq_manual)

# Plot equalization calculation graphs
hist_original = cv2.calcHist([gray], [0], None, [256], [0, 256]).flatten()
hist_equalized = cv2.calcHist([img_eq_manual], [0], None, [256], [0, 256]).flatten()

# Original histogram
fig, ax = plt.subplots(figsize=(6, 5))
ax.plot(hist_original, color='black')
ax.set_title('Original Histogram')
ax.set_xlabel('Pixel Intensity')
ax.set_ylabel('Frequency')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("result/program5/original_histogram.png")
plt.close()

# Equalized histogram
fig, ax = plt.subplots(figsize=(6, 5))
ax.plot(hist_equalized, color='purple')
ax.set_title('Equalized Histogram (Manual)')
ax.set_xlabel('Pixel Intensity')
ax.set_ylabel('Frequency')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("result/program5/equalized_histogram.png")
plt.close()

print("All outputs saved to result/program5/")