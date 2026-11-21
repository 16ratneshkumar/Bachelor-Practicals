# 2. Point Processing Methods.
#     - a. Obtain negative image.
#     - b. Obtain flip image.
#     - c. Thresholding.
#     - d. Contrast stretching.


import cv2
import numpy as np
import os

os.makedirs("result/program2", exist_ok=True)

# Generate synthetic image
img = np.linspace(0, 255, 256, dtype=np.uint8).reshape(16, 16)
img = cv2.resize(img, (256, 256), interpolation=cv2.INTER_NEAREST)
cv2.imwrite("result/program2/original.jpg", img)

# a. Negative image
negative = 255 - img
cv2.imwrite("result/program2/negative.jpg", negative)

# b. Flip image
hor_flipped = cv2.flip(img, 1)  # horizontal flip
cv2.imwrite("result/program2/horizontal_flipped.jpg", hor_flipped)
ver_flipped = cv2.flip(img, 0)  # vertical flip
cv2.imwrite("result/program2/vertical_flipped.jpg", ver_flipped)

# c. Thresholding
_, thresholded = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
cv2.imwrite("result/program2/thresholded.jpg", thresholded)

# d. Contrast stretching
min_val, max_val = np.min(img), np.max(img)
stretched = ((img - min_val) / (max_val - min_val) * 255).astype(np.uint8)
cv2.imwrite("result/program2/contrast_stretched.jpg", stretched)

print("All outputs saved to result/program2/")