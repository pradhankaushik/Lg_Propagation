#!/bin/bash

grd_file=/home/SHARE/resources/GMT/GRD/etopo2.grd
cpt_file=/home/SHARE/resources/GMT/CPT/india_colour.cpt

gmt grdimage $grd_file -C$cpt_file -R64/86/29/43 -JM15 -P -K -B4/4 > /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/good/ray_coverage_map.ps

cd /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/good
#plotting stations
touch stations_coordinates.txt
for file in `ls *BHZ`
do
stla=`saclhdr -STLA $file`
stlo=`saclhdr -STLO $file`
echo $stlo $stla >> stations_coordinates.txt
done



#plotting station names
touch long_lat_stn.txt
for file in `ls *BHZ`
do
stla=`saclhdr -STLA $file`
stlo=`saclhdr -STLO $file`
st_name=`echo $file | awk -F "_" '{print $4}'`
echo $stlo $stla $st_name >> long_lat_stn.txt
done

#gmt pstext long_lat_stn.txt -R65/85/30/42 -JM15 -F+f10p,Helvetica-Bold,white+a1+jLB -O >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/good/ray_coverage_map.ps

#plotting events on the map
touch event_long_lat.txt
for file in `ls *BHZ`
do
evla=`saclhdr -EVLA $file`
evlo=`saclhdr -EVLO $file`
echo $evlo $evla >> event_long_lat.txt
done
gmt psxy event_long_lat.txt -R64/86/29/43 -JM -Sa0.5 -G255/0/0 -O -K -W255/255/255 >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/good/ray_coverage_map.ps


# plotting event_station_pair
touch f_lat_ev_st.txt
#Plotting the ray between source and receiver
#the file f_lat_ev_st.txt contains the long and lat of and event and below it long and lat of corresponding station where it got recorded
for file in `ls *BHZ`
do
evla=`saclhdr -EVLA $file`
evlo=`saclhdr -EVLO $file`
stla=`saclhdr -STLA $file`
stlo=`saclhdr -STLO $file`
echo $evlo $evla >> f_lat_ev_st.txt
echo $stlo $stla >> f_lat_ev_st.txt
done
gmt psxy f_lat_ev_st.txt -R -JM -W1.0,black -P -O -K -A >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/good/ray_coverage_map.ps
gmt psxy stations_coordinates.txt -R64/86/29/43 -JM15 -St0.5 -W0/0/0 -G0/0/255 -O >> /DATA/Lg_Sn_Tomo/IK_Vfiles/NW_Himalaya/rec_section/good/ray_coverage_map.ps

