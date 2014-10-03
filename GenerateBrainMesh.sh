segs=PEDS015_20110812_BrainSegmentation.nii.gz
ext=stl
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
    ImageMath 3 wmt.nii.gz PropagateLabelsThroughMask wms.nii.gz thal.nii.gz $topoits 1
    ThresholdImage 3 wmt_label.nii.gz wmt.nii.gz 1  1
    antsSurf -s [ wmt.nii.gz,255x255x255]  -d $1  -o ${onm}.${ext} -i 0  -a 1.e9 -i 100
  done
done
