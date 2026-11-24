# 1. Basic Image Operations.
#     - a. Read and display image.
#     - b. Resize a given image.
#     - c. Convert a given color image into a corresponding gray-scale image.
#     - d. Convert a given color/gray-scale image into black & white image and draw the image profile.
#     - e. Separate a given color image into three R, G & B planes.
#     - f. Create a color image using separate three R, G and B planes.
#     - g. Write given 2-D data in image file.


import cv2
import numpy as np
import matplotlib.pyplot as plt
import os

# Create result directory
os.makedirs("result/program1", exist_ok=True)

# Load input image
img = cv2.imread("result/input.png")
if img is None:
    # Fallback: generate a sample image
    img = np.zeros((300, 300, 3), dtype=np.uint8)
    img[50:250, 50:250] = [0, 0, 255]  # Blue square
    img[100:200, 100:200] = [0, 255, 0]  # Green square
cv2.imwrite("result/program1/input.jpg", img)

# a. Read and display image
img = cv2.imread("result/program1/input.jpg")

# b. Resize a given image
resized = cv2.resize(img, (150, 150))
cv2.imwrite("result/program1/resized.jpg", resized)

# c. Convert a given color image into a corresponding gray-scale image
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
cv2.imwrite("result/program1/grayscale.jpg", gray)

# d. Convert a given color/gray-scale image into black & white image
_, bw = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)
cv2.imwrite("result/program1/black_white.jpg", bw)

# Image profile
row_profile = gray.mean(axis=1)
col_profile = gray.mean(axis=0)

# e. Separate a given color image into three R, G & B planes
b, g, r = cv2.split(img)
cv2.imwrite("result/program1/b_plane.jpg", b)
cv2.imwrite("result/program1/g_plane.jpg", g)
cv2.imwrite("result/program1/r_plane.jpg", r)

# f. Create a color image using separate three R, G and B planes
merged = cv2.merge((b, g, r))
cv2.imwrite("result/program1/merged_rgb.jpg", merged)

# g. Write given 2-D data in image file
cv2.imwrite("result/program1/output_2d.jpg", gray)

plt.plot(row_profile, label='Row profile')
plt.plot(col_profile, label='Column profile')
plt.title('d. Image profile')
plt.xlabel('Index')
plt.ylabel('Mean intensity')
plt.legend()
plt.grid(True)
plt.savefig("result/program1/image_profile.png")
plt.close()

print("All outputs saved to result/program1/")