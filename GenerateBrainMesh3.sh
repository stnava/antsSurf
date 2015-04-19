#!/bin/bash
seg=ADNI_137_S_0158_MR_MPR__GradWarp__N3__Scaled_Br_20070306171702344_S20209_I42985BrainSegmentation.nii.gz
blob=ADNI_137_S_0158_MR_MPR__GradWarp__N3__Scaled_Br_20070306171702344_S20209_I42985CorticalThickness.nii.gz
ext=stl # or use ply  or  vtk
onm=`echo $seg | cut -d '.' -f 1`
onm=${onm}_kappa
ThresholdImage 3 $seg wm.nii.gz 3 4
ImageMath 3 wm.nii.gz FillHoles wm.nii.gz
ImageMath 3 wm.nii.gz GetLargestComponent wm.nii.gz
SmoothImage 3 wm.nii.gz 0.5 wms.nii.gz
kappa=wmk.nii.gz
SurfaceCurvature wms.nii.gz $kappa 3 0
SmoothImage 3 $kappa 5 overlay.nii.gz
cp $kappa overlay.nii.gz
ThresholdImage 3 wms.nii.gz kblob.nii.gz 0.1 Inf
ConvertScalarImageToRGB 3 overlay.nii.gz overlay_rgb.nii.gz kblob.nii.gz jet none 127.6 128.4 0 255 lookupTable.csv
antsSurf -s [ wm.nii.gz,255x255x255] -b [lookupTable.csv] -f [ overlay_rgb.nii.gz, kblob.nii.gz, 0.5 ] -d 1 -i 10
# antsSurfEx3.png[270x0x270,155x255x255]  -o ${onm}.${ext} -i 10
