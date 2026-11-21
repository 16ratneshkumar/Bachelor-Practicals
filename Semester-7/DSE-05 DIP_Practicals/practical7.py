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

# Find input image
img = None
for p in ["input.jpg", "result/program1/input.jpg", "result/program5/grayscale.jpg", "result/program5/input_img.jpg"]:
    if os.path.exists(p):
        img = cv2.imread(p, 0)
        if img is not None:
            break
if img is None:
    img = np.zeros((256, 256), dtype=np.uint8)
    cv2.rectangle(img, (50, 50), (200, 200), 150, -1)

cv2.imwrite("result/program7/original.jpg", img)

# Salt & Pepper
noisy_sp = img.copy().astype(np.float32)
total = img.size
s_vs_p = 0.5; amount = 0.05
n_s = int(np.ceil(amount*total*s_vs_p)); n_p = int(np.ceil(amount*total*(1-s_vs_p)))
for _ in range(n_s):
    r,c = random.randint(0,img.shape[0]-1), random.randint(0,img.shape[1]-1)
    noisy_sp[r,c]=255
for _ in range(n_p):
    r,c = random.randint(0,img.shape[0]-1), random.randint(0,img.shape[1]-1)
    noisy_sp[r,c]=0
noisy_sp = np.clip(noisy_sp,0,255).astype(np.uint8)
cv2.imwrite("result/program7/salt_pepper_noisy.jpg", noisy_sp)
med = cv2.medianBlur(noisy_sp,3)
cv2.imwrite("result/program7/median_filtered.jpg", med)

# Gaussian
g = np.random.normal(0,10,img.shape)
ng = np.clip(img.astype(float)+g,0,255).astype(np.uint8)
cv2.imwrite("result/program7/gaussian_noisy.jpg", ng)
gf = cv2.GaussianBlur(ng,(5,5),0)
cv2.imwrite("result/program7/gaussian_filtered.jpg", gf)

# Wiener filter (for Gaussian noise restoration)
# scipy.signal.wiener applies adaptive Wiener filtering
wiener_filtered = wiener(ng.astype(np.float32), mysize=5, noise=None)
wiener_filtered = np.clip(wiener_filtered, 0, 255).astype(np.uint8)
cv2.imwrite("result/program7/wiener_filtered.jpg", wiener_filtered)

# Also apply Wiener filter to salt & pepper noise for comparison
wiener_sp = wiener(noisy_sp.astype(np.float32), mysize=5, noise=None)
wiener_sp = np.clip(wiener_sp, 0, 255).astype(np.uint8)
cv2.imwrite("result/program7/wiener_sp_filtered.jpg", wiener_sp)

print("All outputs saved to result/program7/")