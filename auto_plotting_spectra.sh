#!/bin/bash

cd /DATA/Lg_Work/EGU_2021/tomography/Q_Tomo/data_15_deg_tolerance/events

for dir in `ls`
do
cd $dir
for dir2 in `ls`
do
cd $dir2
sac<<!
r *sm
color on inc on
xlim 0.5 5.0
p2
saveimg /home/seismology/Test/${dir}-${dir2}.pdf
q
!
cd ..
done
cd ..
done
