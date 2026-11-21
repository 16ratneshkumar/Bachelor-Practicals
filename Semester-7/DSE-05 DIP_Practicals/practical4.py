# 4. Image Logical Operations.
#     - a. AND operation between two images.
#     - b. OR operation between two images.
#     - c. Calculate intersection of two images.
#     - d. Water marking using X-OR operation.
#     - e. NOT operation (negative image).


import cv2
import numpy as np
import os

os.makedirs("result/program4", exist_ok=True)

# Create sample binary images
img1 = np.zeros((200, 200), dtype=np.uint8)
cv2.rectangle(img1, (50, 50), (120, 120), 255, -1)

img2 = np.zeros((200, 200), dtype=np.uint8)
cv2.circle(img2, (100, 100), 50, 255, -1)

cv2.imwrite("result/program4/image1.jpg", img1)
cv2.imwrite("result/program4/image2.jpg", img2)

# a. AND operation between two images
and_img = cv2.bitwise_and(img1, img2)
cv2.imwrite("result/program4/and.jpg", and_img)

# b. OR operation between two images
or_img = cv2.bitwise_or(img1, img2)
cv2.imwrite("result/program4/or.jpg", or_img)

# c. Calculate intersection of two images
intersection = cv2.bitwise_and(img1, img2)
cv2.imwrite("result/program4/intersection.jpg", intersection)

# d. Water marking using X-OR operation
logo = np.zeros((200, 200), dtype=np.uint8)
cv2.putText(logo, "DIP", (40, 110), cv2.FONT_HERSHEY_SIMPLEX, 1.5, 255, 3)
watermarked = cv2.bitwise_xor(img1, logo)
extracted = cv2.bitwise_xor(watermarked, logo)
cv2.imwrite("result/program4/logo.jpg", logo)
cv2.imwrite("result/program4/watermarked_xor.jpg", watermarked)
cv2.imwrite("result/program4/extracted_xor.jpg", extracted)

# e. NOT operation (negative image)
not_img1 = cv2.bitwise_not(img1)
cv2.imwrite("result/program4/not_image1.jpg", not_img1)

print("All outputs saved to result/program4/")