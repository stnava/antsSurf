#!/bin/bash
segs=ADNI_137_S_0158_MR_MPR__GradWarp__N3__Scaled_Br_20070306171702344_S20209_I42985BrainSegmentation.nii.gz
blob=ADNI_137_S_0158_MR_MPR__GradWarp__N3__Scaled_Br_20070306171702344_S20209_I42985CorticalThickness.nii.gz
ext=stl # or use ply  or  vtk
for seg in $segs ; do
  onm=`echo $seg | cut -d '.' -f 1`
  ThresholdImage 3 $seg wm.nii.gz 3 4
  if [[ ! -s thal.nii.gz ]] ; then
    ThresholdImage 3 $seg thal.nii.gz 4 4
    ImageMath 3 thal.nii.gz MD thal.nii.gz 3
  fi
  ImageMath 3 wm.nii.gz addtozero wm.nii.gz thal.nii.gz
  ImageMath 3 wm.nii.gz FillHoles wm.nii.gz
  ImageMath 3 wm.nii.gz GetLargestComponent wm.nii.gz
  ImageMath 3 wm.nii.gz MD wm.nii.gz 0
  topoits=500
  for smoo in  0.5 ; do
    echo J-Smoov $smoo
    SmoothImage 3 wm.nii.gz $smoo wms.nii.gz
#    ImageMath 3 wm.nii.gz MD wm.nii.gz 2
#    ImageMath 3 wm.nii.gz ME wm.nii.gz 3
#    ImageMath 3 wm.nii.gz GetLargestComponent wm.nii.gz
    ImageMath 3 wmt.nii.gz PropagateLabelsThroughMask wms.nii.gz thal.nii.gz $topoits 0
    ThresholdImage 3 wmt_label.nii.gz wmt.nii.gz 1  1
    antsSurf -s [ wmt.nii.gz,255x255x255]  -d antsSurfEx1.png[0x5x180,255x255x255] -i 10  -o ${onm}.${ext}
    SmoothImage 3 $blob 5 overlay.nii.gz
    ThresholdImage 3 overlay.nii.gz blob.nii.gz 0 0 0 1
    ConvertScalarImageToRGB 3 overlay.nii.gz overlay_rgb.nii.gz blob.nii.gz hot none 0 3.0 0 255 lookupTable.csv

    antsSurf -s [ wmt.nii.gz,255x255x255] -b [lookupTable.csv] -f [ overlay_rgb.nii.gz, blob.nii.gz, 0.5 ] -d antsSurfEx2.png[270x0x270,155x255x255]  -o ${onm}.${ext} -i 10
  done
done
