# 9. Frequency Domain Filtering.
#     - a. Apply FFT on given image.
#     - b. Perform low pass and high pass filtering in frequency domain.
#     - c. Apply IFFT to reconstruct image.


import cv2
import numpy as np
import os

os.makedirs("result/program9", exist_ok=True)

img = cv2.imread("result/input.png", 0)  # Load as grayscale
if img is None:
    for p in ["input.jpg","result/program1/input.jpg","result/program5/grayscale.jpg"]:
        if os.path.exists(p):
            img = cv2.imread(p,0)
            if img is not None: break
if img is None:
    img = np.zeros((256,256),dtype=np.uint8); cv2.rectangle(img,(50,50),(200,200),255,-1)

cv2.imwrite("result/program9/original.jpg", img)

# a. Apply FFT on given image
f = np.fft.fft2(img); fshift = np.fft.fftshift(f)
mag = 20*np.log(np.abs(fshift)+1e-10)
mag = np.clip(mag,0,255).astype(np.uint8)
cv2.imwrite("result/program9/magnitude_spectrum.png", mag)

# b. Perform low pass and high pass filtering in frequency domain
r,c = img.shape; cr,cc = r//2,c//2
mask_lp = np.zeros((r,c),np.uint8); cv2.circle(mask_lp,(cc,cr),30,255,-1)
mask_hp = cv2.bitwise_not(mask_lp)

fsl = fshift*(mask_lp/255.0); fsh = fshift*(mask_hp/255.0)

# c. Apply IFFT to reconstruct image
il = np.abs(np.fft.ifft2(np.fft.ifftshift(fsl))); ih = np.abs(np.fft.ifft2(np.fft.ifftshift(fsh)))
il = np.clip(il,0,255).astype(np.uint8); ih = np.clip(ih,0,255).astype(np.uint8)
cv2.imwrite("result/program9/low_pass_filtered.jpg", il)
cv2.imwrite("result/program9/high_pass_filtered.jpg", ih)

# Save filter masks
cv2.imwrite("result/program9/low_pass_mask.jpg", mask_lp)
cv2.imwrite("result/program9/high_pass_mask.jpg", mask_hp)

print("All outputs saved to result/program9/")