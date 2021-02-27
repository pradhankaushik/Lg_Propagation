#!/bin/bash

cd /DATA/Lg_Sn_Tomo/EGU_2021/SNR/gt_3

for file in `ls v_*`
do

evla=`saclhdr -EVLA $file`
evlo=`saclhdr -EVLO $file`
stla=`saclhdr -STLA $file`
stlo=`saclhdr -STLO $file`
evdp=`saclhdr -EVDP $file`
#if [ `echo "$evla>=30"|bc` -eq 1 ] && [ `echo "$evla<=45"|bc` -eq 1 ] && [ `echo "$evlo>=64"|bc` -eq 1 ] && #[ `echo "$evlo<=86"|bc` -eq 1 ] && [ `echo "$stla>30"|bc` -eq 1 ]; then

if [ `echo "$evdp>0"|bc` -eq 1 ] && [ `echo "$evdp<=40"|bc` -eq 1 ]; then
cp $file /DATA/Lg_Sn_Tomo/EGU_2021/Depth/0-40
fi

if [ `echo "$evdp>40"|bc` -eq 1 ] && [ `echo "$evdp<=80"|bc` -eq 1 ]; then
cp $file /DATA/Lg_Sn_Tomo/EGU_2021/Depth/40-80
fi

if [ `echo "$evdp>80"|bc` -eq 1 ]; then
cp $file /DATA/Lg_Sn_Tomo/EGU_2021/Depth/80+
fi
#cp $file /DATA/Lg_Sn_Tomo/EGU_2021/raw_files
#fi
done
