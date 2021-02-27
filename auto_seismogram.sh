#!/bin/bash

cd /DATA/Lg_Sn_Tomo/EGU_2021/raw_files

for file in `ls *BHZ`
do

sac<<!
r $file
rmean
rtrend
qdp off
bp co 0.5 5.0 p 2
ppk
q
!

echo -n "Enter select as 1 and reject as 0  "
read value
if [ $value -eq 1 ]; then
cp $file /DATA/Lg_Sn_Tomo/EGU_2021/good_seismograms
elif [ $value -eq 0 ]; then
cp $file /DATA/Lg_Sn_Tomo/EGU_2021/bad_seismograms
else
echo "You have entered a wrong value!"
fi

done
