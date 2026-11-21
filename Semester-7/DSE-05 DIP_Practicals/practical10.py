# 10. Edge Detection.
#     - Edge detection using different edge detection mask.


import cv2
import numpy as np
import os

os.makedirs("result/program10", exist_ok=True)

img = None
for p in ["input.jpg","result/program1/input.jpg","result/program5/grayscale.jpg"]:
    if os.path.exists(p):
        img = cv2.imread(p,0)
        if img is not None: break
if img is None:
    img = np.zeros((256,256),dtype=np.uint8); cv2.rectangle(img,(50,50),(200,200),255,-1)

cv2.imwrite("result/program10/original.jpg", img)

# Sobel
sx = cv2.Sobel(img,cv2.CV_64F,1,0,ksize=3); sy = cv2.Sobel(img,cv2.CV_64F,0,1,ksize=3)
sob = np.clip(np.hypot(sx,sy),0,255).astype(np.uint8)

# Prewitt
kx=np.array([[1,1,1],[0,0,0],[-1,-1,-1]]); ky=np.array([[-1,0,1],[-1,0,1],[-1,0,1]])
px=cv2.filter2D(img,-1,kx); py=cv2.filter2D(img,-1,ky)
pre = np.clip(np.hypot(px.astype(float),py.astype(float)),0,255).astype(np.uint8)

# Roberts
rx=np.array([[1,0],[0,-1]]); ry=np.array([[0,1],[-1,0]])
rxv=cv2.filter2D(img,-1,rx); ryv=cv2.filter2D(img,-1,ry)
rob = np.clip(np.hypot(rxv.astype(float),ryv.astype(float)),0,255).astype(np.uint8)

# Canny
can = cv2.Canny(img,50,150)
cv2.imwrite("result/program10/sobel.jpg", sob)
cv2.imwrite("result/program10/prewitt.jpg", pre)
cv2.imwrite("result/program10/roberts.jpg", rob)
cv2.imwrite("result/program10/canny.jpg", can)

print("All outputs saved to result/program10/")