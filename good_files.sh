#!/bin/bash

cd /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/

for dir in `ls`
do
cd $dir
cp v* ../
cd ..
done
