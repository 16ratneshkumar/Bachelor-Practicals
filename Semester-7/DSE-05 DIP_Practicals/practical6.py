# 6. Geometric Transformations.
#     - a. Translation.
#     - b. Scaling.
#     - c. Rotation.
#     - d. Shrinking.
#     - e. Zooming.


import cv2
import numpy as np
import os

os.makedirs("result/program6", exist_ok=True)

# Create sample image
img = np.zeros((150, 150, 3), dtype=np.uint8)
cv2.rectangle(img, (30, 30), (90, 90), (0, 255, 0), -1)
cv2.imwrite("result/program6/original.jpg", img)

# a. Translation
h, w = img.shape[:2]
M = np.float32([[1, 0, 50], [0, 1, 30]])
translated = cv2.warpAffine(img, M, (w, h))
cv2.imwrite("result/program6/translated.jpg", translated)

# b. Scaling
scaled = cv2.resize(img, None, fx=1.5, fy=1.5, interpolation=cv2.INTER_LINEAR)
cv2.imwrite("result/program6/scaled.jpg", scaled)

# c. Rotation
M_rot = cv2.getRotationMatrix2D((w/2, h/2), 45, 1)
rotated = cv2.warpAffine(img, M_rot, (w, h))
cv2.imwrite("result/program6/rotated.jpg", rotated)

# d. Shrinking
shrunk = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_AREA)
cv2.imwrite("result/program6/shrunk.jpg", shrunk)

# e. Zooming
zoomed = cv2.resize(img, None, fx=2.0, fy=2.0, interpolation=cv2.INTER_CUBIC)
cv2.imwrite("result/program6/zoomed.jpg", zoomed)

print("All outputs saved to result/program6/")