import os
import numpy as np
import SimpleITK as sitk 

dir='orig_data/img'
odir='npy_img'
if not os.path.exists(odir):
  os.makedirs(odir)

for file in os.listdir(dir):
  # Reads the image using SimpleITK
  itkimage = sitk.ReadImage(os.path.join(dir,file))
  # Convert the image to a  numpy array first and then shuffle the dimensions to get axis in the order z,y,x
  ct_scan = sitk.GetArrayFromImage(itkimage)
  f=open(odir+"/"+file[:-4]+".npy","w")
  np.save(f,ct_scan)
  f.close()

