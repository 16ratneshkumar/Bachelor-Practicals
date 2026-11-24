# 8. Spatial Filtering.
#     - a. Understand 1-D and 2-D convolution process.
#     - b. Use 3x3 mask for low pass filter and high pass filter.


import cv2
import numpy as np
import os
import random

random.seed(42)
np.random.seed(42)

os.makedirs("result/program8", exist_ok=True)

# Load image
img = cv2.imread("result/input.png", 0)  # Load as grayscale
if img is None:
    for p in ["input.jpg", "result/program1/input.jpg", "result/program5/grayscale.jpg"]:
        if os.path.exists(p):
            img = cv2.imread(p, 0)
            if img is not None: break
if img is None:
    img = np.zeros((128,128),dtype=np.uint8); cv2.rectangle(img,(20,20),(100,100),255,-1)

cv2.imwrite("result/program8/original.jpg", img)
imgf = img.astype(np.float32)

# 1D conv
k1 = np.array([1,2,1],dtype=np.float32)/4.0
conv1d = np.convolve(imgf[0,:], k1, mode='same')

# LP
klp = np.ones((3,3),dtype=np.float32)/9.0
lp = cv2.filter2D(imgf,-1,klp)
cv2.imwrite("result/program8/low_pass.jpg", lp.astype(np.uint8))
# HP
khp = np.array([[-1,-1,-1],[-1,8,-1],[-1,-1,-1]],dtype=np.float32)
hp = cv2.filter2D(imgf,-1,khp)
hp = np.clip(hp,0,255).astype(np.uint8)
cv2.imwrite("result/program8/high_pass.jpg", hp)

print("All outputs saved to result/program8/")