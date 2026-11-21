# 3. Image Arithmetic Operations.
#     - a. Addition of two images.
#     - b. Subtract one image from other image.
#     - c. Calculate mean value of image.
#     - d. Different brightness by changing mean value.


import cv2
import numpy as np
import os

os.makedirs("result/program3", exist_ok=True)

# Create sample images
img1 = np.zeros((256, 256), dtype=np.uint8)
cv2.rectangle(img1, (50, 50), (150, 150), 100, -1)

img2 = np.zeros((256, 256), dtype=np.uint8)
cv2.circle(img2, (150, 150), 70, 150, -1)

cv2.imwrite("result/program3/image1.jpg", img1)
cv2.imwrite("result/program3/image2.jpg", img2)

# a. Addition of two images
added = cv2.add(img1, img2)
cv2.imwrite("result/program3/added.jpg", added)

# b. Subtract one image from other image
subtracted1 = cv2.subtract(img1, img2)
subtracted2 = cv2.subtract(img2, img1)
cv2.imwrite("result/program3/subtracted_img1_img2.jpg", subtracted1)
cv2.imwrite("result/program3/subtracted_img2_img1.jpg", subtracted2)

# c. Calculate mean value of image
mean1 = np.mean(img1)
mean2 = np.mean(img2)
with open("result/program3/mean_values.txt", "w") as f:
    f.write(f"Mean of image1: {mean1}\n")
    f.write(f"Mean of image2: {mean2}\n")

# d. Different brightness by changing mean value
# Use calculated mean values (mean1, mean2) to adjust brightness
# Brighten img1 by adding mean2, darken by subtracting mean2
brightened = cv2.add(img1, int(mean2))
darkened = cv2.subtract(img1, int(mean2))

cv2.imwrite("result/program3/brightened.jpg", brightened)
cv2.imwrite("result/program3/darkened.jpg", darkened)

print("All outputs saved to result/program3/")