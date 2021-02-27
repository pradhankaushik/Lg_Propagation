#!/bin/bash

cd /DATA/Lg_Work/EGU_2021/tomography/Q_Tomo/data_15_deg_tolerance/events/2013294022713/BADR-UDHM

del1=`saclhdr -DIST v_2013294022713_IK_BADR.BHZ`
stlat1=`saclhdr -STLA v_2013294022713_IK_BADR.BHZ`
stlog1=`saclhdr -STLO v_2013294022713_IK_BADR.BHZ`
del2=`saclhdr -DIST v_2013294022713_IK_UDHM.BHZ`
stlat2=`saclhdr -STLA v_2013294022713_IK_UDHM.BHZ`
stlog2=`saclhdr -STLO v_2013294022713_IK_UDHM.BHZ`

echo $del1 $del2

echo $stlat1 $stlog1 $stlat2 $stlog2


