#!/bin/bash

cd /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section

cat dir_list.txt | while read line 
do 
dir_lat=`echo $line | awk -F "-" '{print $1}'`
dir_long=`echo $line | awk -F "-" '{print $2}'`
cd /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya
for file in `ls *BH?`
do
evla=`saclhdr -EVLA $file`
evlo=`saclhdr -EVLO $file`

if [ `echo "$evla==$dir_lat"|bc` -eq 1 ] && [ `echo "$evlo==$dir_long"|bc` -eq 1 ]; then
destination=`echo $dir_lat"-"$dir_long`
cp /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/$file /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/$destination/
fi
done
cd rec_section/
done

