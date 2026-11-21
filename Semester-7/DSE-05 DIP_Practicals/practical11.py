# 11. Morphological Operations.
#     - Image morphological operations: erosion and dilation.


import cv2
import numpy as np
import os

os.makedirs("result/program11", exist_ok=True)

img = None
for p in ["input.jpg","result/program1/input.jpg","result/program5/grayscale.jpg"]:
    if os.path.exists(p):
        img = cv2.imread(p,0)
        if img is not None: break
if img is None:
    img = np.zeros((200,200),dtype=np.uint8); cv2.putText(img,'DIP',(40,120),cv2.FONT_HERSHEY_SIMPLEX,2.5,255,5)

cv2.imwrite("result/program11/original.jpg", img)

k = np.ones((5,5),np.uint8)
er = cv2.erode(img,k,iterations=1)
di = cv2.dilate(img,k,iterations=1)
op = cv2.morphologyEx(img,cv2.MORPH_OPEN,k)
cl = cv2.morphologyEx(img,cv2.MORPH_CLOSE,k)
cv2.imwrite("result/program11/erosion.jpg", er)
cv2.imwrite("result/program11/dilation.jpg", di)
cv2.imwrite("result/program11/opening.jpg", op)
cv2.imwrite("result/program11/closing.jpg", cl)

print("All outputs saved to result/program11/")