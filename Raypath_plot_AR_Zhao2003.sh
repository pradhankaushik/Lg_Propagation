#!/bin/bash
#
# script name: Raypath_plot_AR_Zhao2003.gmt5

#  plot of AR value coloured Lg ray path on Mercator projection.
#  Takes the input file in this format:
#
# Filename                       Dist     Lg/Pn-m  Lg/Sn-m  Sn/Pn-m  Lg/Pn-v  Lg/Sn-v  Sn/Pn-v  Lg/Pn-r  Lg/Sn-r  Sn/Pn-r
# Filter: bp co 0.25 5 p 2 n 4
#
# v_2011261124051_CB_CAD_00.BHZ    978.87    27.39     2.68    10.22    49.99     2.34    21.37    32.31     2.05    15.77
# v_2011261124051_CB_GOM_00.BHZ   1131.90    18.86     5.99     3.15    39.08     2.06    18.93    28.58     6.12     4.67
# v_2011261124051_CB_TNC_00.BHZ   1077.86    28.41     3.56     7.99    49.56     5.43     9.12    26.52     2.46    10.76
#
# to create such a file run: /home/mitra/SCRIPTS-SM/Lg_scripts/All_AR_Zhao2003.sh

######################################################################
cd /DATA/Lg_Sn_Tomo/EGU_2021/Depth/0-40/Mw5-6/2016225180101
echo "1. v_???---Z SAC files in this directory: For Event and Station information."
echo "2. Amplitude Ratio file (eg. AR_Sikkim2011.txt): For Aplitude Ratio. "
echo
#ls *.txt
echo
#echo "Input the Amplitude Ratio file (eg. AR_Sikkim2011.txt)"
#read infile
infile=AR_z_files.txt

# Seggregating the files for Lg/Sn 0-1, 1-2 and 2+
awk 'NR>3 {if ($7>0 && $7<1) print $0}' $infile > temp_0
awk 'NR>3 {if ($7>=1 && $7<2) print $0}' $infile > temp_1
awk 'NR>3 {if ($7>=2) print $0}' $infile > temp_2

echo
echo "Written files temp_0 temp_1 temp_2"

# LOOP-1 START
# Running through the temp files
for list in temp_0 temp_1 temp_2
do

echo
echo "working on file $list"

# cleaning up to start
rm -f ray_covg.txt temp-event_list.txt temp-sta_list.txt

# LOOP-2 START
n=`wc -l $list | awk '{print $1}'`
a=1
while [ $a -le $n ]
do

echo "Extracting line $a from file $list"
file=`awk 'NR==num {print $1}' num="$a" $list`

# Checking if the file name stars with a v or $dir name
first=` echo $file | awk -F_ '{print $1}'`

if [ $first = "v" ] ; then
	sta=` echo $file | awk -F"_" '{print $4}' | awk -F"." '{print $1}' `
	net=` echo $file | awk -F"_" '{print $3}' `
	eventnm=` echo $file | awk -F"_" '{print $2}' `
	echo "Event-name $eventnm network $net station-name $sta"

elif [ $first != "v" ] ; then
	sta=` echo $file | awk -F"_" '{print $3}' | awk -F"." '{print $1}' `
	net=` echo $file | awk -F"_" '{print $2}' `
	eventnm=` echo $file | awk -F"_" '{print $1}' `
	echo "Event-name $eventnm network $net station-name $sta"
fi

ev_lat=`saclhdr	-EVLA ${file}`
ev_long=`saclhdr -EVLO ${file}`
sta_lat=`saclhdr -STLA ${file}`
sta_long=`saclhdr -STLO ${file}`

# printing to screen
echo "event lat, long $ev_lat $ev_long"
echo "station lat, long $sta_lat $sta_long"

# writing the ray coverage input file
echo "${sta_long} ${sta_lat} " >> ${list}_ray_covg.txt
echo "${ev_long} ${ev_lat} " >> ${list}_ray_covg.txt
echo "> " >> ${list}_ray_covg.txt

# wrting the temporary event location list file
echo "${ev_long} ${ev_lat} ${eventnm}" >> temp-event_list.txt

# wrting the temporary station location list file
echo "${sta_long} ${sta_lat} ${sta}" >> temp-sta_list.txt
2015341080944
# LOOP-2 END
# Looping through the lines of the temp_? file
a=`echo $a + 1 | bc`
done

# only getting a unique set of event and station locations
cat temp-event_list.txt | sort | uniq > ${list}_event_list.txt
cat temp-sta_list.txt | sort | uniq > ${list}_sta_list.txt

# LOOP-1 END
# Looping over temp_? files
done

## overriding gmt defaults for paper media
gmt set MAP_FRAME_TYPE plain
gmt set MAP_FRAME_WIDTH 2p
gmt set MAP_TICK_PEN_PRIMARY thicker,black
gmt set FONT_ANNOT_PRIMARY 16p,Times,black
# Page Orientation
#gmt set PS_PAGE_ORIENTATION PORTRAIT
gmt set PS_PAGE_ORIENTATION LANDSCAPEAR_z_files.txt

# Setting CPT file as per choice
#echo "Input "b" for Black and White (gray scale plot) or "c" for Colour plot"
#read ans
#if [ $ans = "b" ]; then
#echo "Creating BW plot..."
#echo
#cptfile=/home/mitra/gmt_maps/CPT_files/BW_all_india.cpt
#cptfile=/home/SHARE/resources/GMT/CPT/Grey_scale_Density.cpt
#output="bw_raypath-${infile}.ps"
#echo "output file is $output"

#elif [ $ans = "c" ]; then
echo "Creating COLOUR plot..."
echo
#cptfile=/home/mitra/gmt_maps/CPT_files/india_colour_cont_high.cpt
cptfile=/home/SHARE/resources/GMT/CPT/india_colour.cpt
output="raypath-${infile}_map.ps"
echo "output file is $output"

#else
#echo "Input should have been b or c - Quitting..."
#exit
#fi

# Bounds
Slat=`cat temp_?_sta_list.txt temp_?_event_list.txt | sort -g -k2 | head -1 | awk '{printf("%.0f\n", $2-2)}'`
Elat=`cat temp_?_sta_list.txt temp_?_event_list.txt | sort -g -k2 | tail -1 | awk '{printf("%.0f\n", $2+2)}'`
Slong=`cat temp_?_sta_list.txt temp_?_event_list.txt | sort -g -k1 | head -1 | awk '{printf("%.0f\n", $1-2)}'`
Elong=`cat temp_?_sta_list.txt temp_?_event_list.txt | sort -g -k1 | tail -1 | awk '{printf("%.0f\n", $1+2)}'`

echo "Bounds are ${Slong}/${Elong}/${Slat}/${Elat}"
bounds="-R${Slong}/${Elong}/${Slat}/${Elat}"

proj="-JM15.0"
bounds="-R${Slong}/${Elong}/${Slat}/${Elat}"
# For Bay of Bengal
#bounds="-R80/105/15/35"
# For Ganga Basin
#bounds="-R64.5/95.5/19.5/36.5"
# For Sikkim
#bounds="-R87.8/89.2/26.5/28.2"
# For India
#bounds="-R67/97/5/36"
#miscB="-Ba0.2f0.1g0.1/a0.2f0.1g0.1:WeSn"
#miscB="-Ba0.5f0.1::/a0.5f0.1::WeSn"
miscB="-Ba5f0.5WSne"
#origin="-X2.0 -Y6.0"
misc="-V -P"

#  plot of NE india with the coast and the elevation.
# GRD file (chosing the one based on region)
#if [ $Slat -ge 0 ] && [ $Elat -le 40 ] && [ $Slong -ge 60 ] && [ $Elong -le 100 ]; then
#grdfile=/home/mitra/gmt_maps/GRD_files_India/SRTM3_Eurasia/SRTM_grd/NE_india/N24-26_E087-096.grd
#grdfile=/home/SHARE/resources/GMT/GRD/kashmir_srtm.grd
#grdfile=/home/SHARE/resources/GMT/GRD/INDIA_cont.grd
grdfile=/home/SHARE/resources/GMT/GRD/etopo2.grd
#else
#grdfile=/home/SHARE/resources/GMT/GRD/kashmir_srtm.grd
#grdfile=/home/SHARE/resources/GMT/GRD/INDIA_cont.grd
#grdfile=/home/SHARE/resources/GMT/GRD/etopo2.grd
#fi

#gmt grdraster 11 -Gshilong.grd $bounds -I.5m/.5m
#gmt grd2cpt shilong.grd -Ctopo -S0/1000/10  -I -V -Z > shillong.cpt

gmt grdgradient ${grdfile} -Nt1 -A45 -GINDIA_temp.grd

gmt grdimage ${grdfile} -IINDIA_temp.grd -C${cptfile} $bounds $miscB $proj $misc -K > $output

#gmt psscale -D12c/18c/19c/0.5ch -C${cptfile} -B2000/:mts: -O -K >> $output

# plotting the coastline
#
# With International border
#gmt pscoast $proj $bounds -BwEsNa1f0.5/a1f0.5 -W1 -Di -A250 -N1/1p,0/0/0,. -Ira/0/0/200 -S0/0/200 -E -O -K ${misc} >> $output
# Without International Border
gmt pscoast $proj $bounds $miscB -W1 -Di -A250 -I1/0.25p,0/0/200 -O -K $misc >> $output
# Kashmir India border Digitised
#gmt psxy /home/mitra/gmt_maps/GRD_files_India/kashmir.dat -K -O $proj $bounds -W1p,0/0/0,. ${misc} >> $output


# Running through the temp files
for pre in temp_0 temp_1 temp_2
do

	# Setting colour
	if [ $pre = "temp_0" ]; then
	cl=red
	elif [ $pre = "temp_1" ]; then
	cl=black
	elif [ $pre = "temp_2" ]; then
	cl=blue
	fi

# Plotting the ray pathAR_z_files.txt for event to station.
echo
echo "Plotting Raypaths ..."
echo
gmt psxy ${pre}_ray_covg.txt -K -O $proj -R -W1,${cl} $misc >> $output

# Station naming and plotting.
echo
echo "Plotting Stations and Naming ..."
echo
# Naming
#awk '{print $1, $2-0.4, $3}' ${pre}_sta_list.txt | gmt pstext -K -R -O -JM -F+f12p,Times-Bold,${cl}+jCT -Gwhite $misc >> $output
# plotting triangles
awk '{print $1, $2}' ${pre}_sta_list.txt | gmt psxy -O -K -JM -R -St0.5c -W1,black -Gblue $misc >> $output


# Plotting event and Naming (if required)
echo
echo "Plotting Event ..."
echo
# Naming
#awk '{print $1, $2, $3}' ${pre}_event_list.txt | gmt pstext -K -R -O -JM -F+f12p,Times-Bold,${cl}+jCT -Gwhite $misc >> $output
# Plotting circle
awk '{print $1, $2}' ${pre}_event_list.txt | gmt psxy -K -O -JM -R -Sa0.5c -W1,black -Gwhite $misc >> $output

done

#############
# end of plot
gmt psxy $bounds $proj -O < /dev/null >> $output

# Cleaning up ######################
# getting rid of the temporary files
rm -f gmt.conf gmt.history INDIA_temp.grd list1 temp_? temp_?_event_list.txt temp-event_list.txt temp_?_ray_covg.txt temp-sta_list.txt temp_?_sta_list.txt

# Plotting the postscript file
gs $output

# end
