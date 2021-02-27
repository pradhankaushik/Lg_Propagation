#!/bin/bash

grd_file=/home/SHARE/resources/GMT/GRD/etopo2.grd
cpt_file=/home/SHARE/resources/GMT/CPT/india_colour.cpt
cd /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/depth/0-40
gmt grdimage $grd_file -C$cpt_file -R65/85/30/42 -JM15 -P -K -B3/3 > /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/depth/0-40/15_degree.ps



#plotting stations
#touch stations_coordinates.txt
#for file in `ls *BHZ`
#do
#stla=`saclhdr -STLA $file`
#stlo=`saclhdr -STLO $file`
#echo $stlo $stla >> stations_coordinates.txt
#done

gmt psxy stations_coordinates_15.txt -R65/85/30/42  -JM15 -St0.5 -W51/51/255 -G255/255/255 -O -K >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/depth/0-40/15_degree.ps

#plotting events on the map
#touch event_long_lat.txt
#for file in `ls *BHZ`
#do
#evla=`saclhdr -EVLA $file`
#evlo=`saclhdr -EVLO $file`
#echo $evlo $evla >> event_long_lat.txt
#done
gmt psxy 15_event_long_lat.txt -R65/85/30/42 -JM15 -Sa0.5 -G255/255/255 -O -W255/0/0 -K >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/depth/0-40/15_degree.ps

#plotting colored ray between event and station
#gmt psxy test_zero_one.txt -R -JM -W0.5,red -P -O -A -K >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/color_coded_map.ps

gmt psxy two_stations_15_test.txt -R -JM -W0.5,black -P -O -A >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/depth/0-40/15_degree.ps

#gmt psxy test_two_plus.txt -R -JM -W0.5,blue -P -O -A >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/color_coded_map.ps


#gv ${/DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/depth/0-40/10_degree.ps}
