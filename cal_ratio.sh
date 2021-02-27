#!/bin/bash
cd /DATA/Lg_Work/EGU_2021/tomography/Q_Tomo/data_15_deg_tolerance/events/2013294022713/BADR-UDHM

sac<<!
r v_2013294022713_IK_BADR.BHZ_Lg_sm v_2013294022713_IK_UDHM.BHZ_Lg_sm
cut B 0.5 5.0
r
w temp1 temp2 
cut off
r temp1
divf temp2
evaluate to x 285.605 / 328.544
evaluate to z (sqrt %x)
mul %z
log
evaluate to y 3.5 / 3.14 / 50.9358902
mul %y 
w test.sac
q
!

sac2xy test.sac f_y.txt
more f_y.txt | awk '{print log($1),log($2)}' >> log_f_log_y.txt
rm temp1 temp2 test.sac
