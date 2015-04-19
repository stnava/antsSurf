#!/bin/bash
seg=$1 # ants cortical thickness style seg
if [[ ${#seg}  -lt 4 ]] ; then
  echo usage
  echo $0 sixClassSegmentation.nii.gz
  exit
fi
ext=stl # or use ply  or  vtk
onm=`echo $seg | cut -d '.' -f 1`
onm=${onm}_kappa
ThresholdImage 3 $seg wm.nii.gz 3 4
# SetDirectionByMatrix wm.nii.gz wm.nii.gz 1 0 0 0 1 0 0 0 1
ImageMath 3 wm.nii.gz FillHoles wm.nii.gz
ImageMath 3 wm.nii.gz GetLargestComponent wm.nii.gz
SmoothImage 3 wm.nii.gz 1.0 wms.nii.gz
kappa=wmk.nii.gz
SurfaceCurvature wms.nii.gz $kappa 1.5 0
kappa=wmk.nii.gz
SmoothImage 3 $kappa 1 overlay.nii.gz
cp $kappa overlay.nii.gz
ThresholdImage 3 wms.nii.gz kblob.nii.gz 0.1 Inf
ConvertScalarImageToRGB 3 overlay.nii.gz overlay_rgb.nii.gz kblob.nii.gz jet none 127.6 128.4 0 255 lookupTable.csv
antsSurf -s [ wm.nii.gz,255x255x255] -f [ overlay_rgb.nii.gz, kblob.nii.gz, 0.5 ] -i 25 -d antsSurfEx3.png[0x170x0,155x255x255]  -o ${onm}.${ext}

# surface classification
SurfaceCurvature wms.nii.gz $kappa 1.5 5
ThresholdImage 3 $kappa p1.nii.gz 1 1
ThresholdImage 3 $kappa n1.nii.gz 2 2
ThresholdImage 3 $kappa p2.nii.gz 3 3
ThresholdImage 3 $kappa n2.nii.gz 4 4
ThresholdImage 3 $kappa p3.nii.gz 5 5
ThresholdImage 3 $kappa n3.nii.gz 6 6
MultiplyImages 3 p1.nii.gz 2 p1.nii.gz
MultiplyImages 3 p2.nii.gz 2 p2.nii.gz
MultiplyImages 3 p3.nii.gz 2 p3.nii.gz
ImageMath 3 p1.nii.gz + p1.nii.gz p2.nii.gz
ImageMath 3 p1.nii.gz + p1.nii.gz p3.nii.gz
ImageMath 3 p1.nii.gz + p1.nii.gz n1.nii.gz
ImageMath 3 p1.nii.gz + p1.nii.gz n2.nii.gz
ImageMath 3 p1.nii.gz + p1.nii.gz n3.nii.gz
cp p1.nii.gz overlay.nii.gz
SmoothImage 3 overlay.nii.gz 1.0 overlay.nii.gz
ThresholdImage 3 wms.nii.gz kblob.nii.gz 0.1 Inf
ConvertScalarImageToRGB 3 overlay.nii.gz overlay_rgb.nii.gz kblob.nii.gz hot none 1 2 0 255 lookupTable.csv
antsSurf -s [ wm.nii.gz,255x255x255] -f [ overlay_rgb.nii.gz, kblob.nii.gz, 0.5 ] -i 25 -d antsSurfEx4.png[0x170x0,155x255x255]  -o ${onm}.${ext}



# antsSurf -s [ wm.nii.gz,255x255x255] -b [lookupTable.csv] -f [ overlay_rgb.nii.gz, kblob.nii.gz, 0.5 ] -d 1 -i 25
#

# 90x270x0 top view
