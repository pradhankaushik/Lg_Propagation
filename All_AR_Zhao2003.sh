#!/bin/bash
#	script name:
cd /DATA/Lg_Sn_Tomo/EGU_2021/SNR/gt_3
#for dir in `ls`
#do
#cd $dir
# Initializing

rm -f tmp

echo "RS_list.txt of files for Record Section Plot"
echo
echo "Will contain file names as follows"
echo "**********************************"
echo "v_2011261124051_ER_MOHN.BHZ"
echo "v_2011261124051_IM_DGPR.BHZ"
echo "v_2011261124051_IM_JBP.HHZ"
echo "**********************************"
echo
ls *.txt
echo
echo "Input the list of files to use for calculating the amplitude ratios (eg. RS_list.txt)"
#read list
list=z_files.txt
# Setting output filename
outfile=AR_${list}

# Initializing output files
echo "# Filename                       Dist     Lg/Pn-m  Lg/Sn-m  Sn/Pn-m  Lg/Pn-v  Lg/Sn-v  Sn/Pn-v  Lg/Pn-r  Lg/Sn-r  Sn/Pn-r" > ${outfile}
rm -f log.AR

###############################################################################
# Bandpass Filter the seismograms before plotting
#echo "Do you want to bandpass filter the seismogram before plotting (Y/N)?"
#read ans

#if [ $ans = "Y" ] || [ $ans = "y" ] ; then
#echo "Input bandpass corners:"
#echo "Lower corner (eg. 0.01 Hz)?"
#read lco
lco=0.5
#echo "Upper corner (eg. 0.1 Hz)?"
#read uco
uco=5.0
#echo "Filtering between $lco and $uco with four poles and two passes"
echo "# Filter: bp co $lco $uco p 2 n 4" >> ${outfile}
echo "#" >> ${outfile}
# Control
x=1

#elif [ $ans = "N" ] || [ $ans = "n" ] ; then
#echo "Continuing without filtering"
#echo "# Filter: None" >> ${outfile}
#echo "#" >> ${outfile}
# Control
x=0

#else
#echo "Answer should have been Y or N. Quitting..."
#exit

#fi

# Running through the files
n=`wc -l $list | awk '{print $1}'`
a=1
while [ $a -le $n ]
do

echo "Extracting line $a from file $list"
file=`awk 'NR==num {print $1}' num="$a" $list`

# Getting the Hypocentral Distance from SAC Header
dist=`saclhdr -DIST $file`

# Getting file name without component
rfile=`ls $file | awk -F. '{print $1}'`
pcmp=`ls $file | awk -F. '{print $2}' | cut -c1-2`


# STEP-1 # ROTATING HORIZONTALS N-E to R-T ###############################################

# Checking if all components (Z,N,E) present
if [ -e ${rfile}.${pcmp}Z ] && [ -e ${rfile}.${pcmp}N ] && [ -e ${rfile}.${pcmp}E ]; then
echo "All components present. Rotating Horizontals..."

# Rotating in SAC
sac<<!
r ${rfile}.${pcmp}N ${rfile}.${pcmp}E
rot to gcp
w ${rfile}.${pcmp}R ${rfile}.${pcmp}T
r ${rfile}.${pcmp}R
ch KCMPNM ${pcmp}R
wh
r ${rfile}.${pcmp}T
ch KCMPNM ${pcmp}T
wh
q
!

# STEP-2 # FILTERING THE TRACES (IF CHOSEN) ##############################################

# Applying the band-pass filter if chosen
if [ $x -eq 1 ]; then
	# Filtering
	echo "echo on" > f.m
	echo "r ${rfile}.${pcmp}Z ${rfile}.${pcmp}R ${rfile}.${pcmp}T" >> f.m
	echo "rtr" >> f.m
	echo "rmean" >> f.m
	echo "bp co $lco $uco p 2 n 4" >> f.m
	echo "w temp.Z temp.R temp.T" >> f.m
	echo "q" >> f.m

# running sac macro
sac f.m
# cleaning
rm -f f.m

elif [ $x -eq 0 ]; then
	# No Filtering
	cp ${rfile}.${pcmp}Z temp.Z
	cp ${rfile}.${pcmp}R temp.R
	cp ${rfile}.${pcmp}T temp.T

fi


# STEP-3 # WINDOWING THE Pn, Sn and Lg phases ##############################################

# Setting up SAC MACRO to cut traces
echo "echo on" > sac.m
echo "r temp.Z temp.R temp.T" >> sac.m
# Cutting Pn window: velocity 8.1 to 7.7 km/s
echo "EVALUATE TO spnt &1,DIST/8.1" >> sac.m
echo "EVALUATE TO epnt &1,DIST/7.7" >> sac.m
echo "cut B %spnt %epnt" >> sac.m
echo "r" >> sac.m
echo "w prepend Pn_" >> sac.m
echo "cut off" >> sac.m
# Cutting Sn window: velocity 4.6 to 4.2 km/s
echo "r temp.Z temp.R temp.T" >> sac.m
echo "EVALUATE TO ssnt &1,DIST/4.6" >> sac.m
echo "EVALUATE TO esnt &1,DIST/4.2" >> sac.m
echo "cut B %ssnt %esnt" >> sac.m
echo "r" >> sac.m
echo "w prepend Sn_" >> sac.m
echo "cut off" >> sac.m
# Cutting Lg window: velocity 3.6 to 2.8 km/s
echo "r temp.Z temp.R temp.T" >> sac.m
echo "EVALUATE TO slgt &1,DIST/3.6" >> sac.m
echo "EVALUATE TO elgt &1,DIST/2.8" >> sac.m
echo "cut B %slgt %elgt" >> sac.m
echo "r" >> sac.m
echo "w prepend Lg_" >> sac.m
echo "cut off" >> sac.m
echo "q" >> sac.m

# running sac macro
sac sac.m

# STEP-4 # Computing the amplitude ratios ##########################################################

# Creating the xy files sequentially
#need to check this step
#ls Pn_temp.Z Pn_temp.R Pn_temp.T Sn_temp.Z Sn_temp.R Sn_temp.T Lg_temp.Z Lg_temp.R Lg_temp.T > list1
#sac2xy < list1
sac2xy Pn_temp.Z Pn_temp.Z.xy
sac2xy Pn_temp.R Pn_temp.R.xy
sac2xy Pn_temp.T Pn_temp.T.xy

sac2xy Sn_temp.Z Sn_temp.Z.xy
sac2xy Sn_temp.R Sn_temp.R.xy
sac2xy Sn_temp.T Sn_temp.T.xy

sac2xy Lg_temp.Z Lg_temp.Z.xy
sac2xy Lg_temp.R Lg_temp.R.xy
sac2xy Lg_temp.T Lg_temp.T.xy



# STEP-4a # MAXIMUM AMPLITUDE RATIOS #######################

# Selecting maximum amplitudes for Pn (Z), Sn (T) and Lg (Z) # squaring and root to remove negative amplitude
pnmax=`sort -g -k2 Pn_temp.Z.xy | tail -1 | awk '{print (($2**2)**0.5)}'`
snmax=`sort -g -k2 Sn_temp.T.xy | tail -1 | awk '{print (($2**2)**0.5)}'`
lgmax=`sort -g -k2 Lg_temp.Z.xy | tail -1 | awk '{print (($2**2)**0.5)}'`

# Calculating the MAX AMPLITUDE ratios
lgpn=`echo $lgmax $pnmax | awk '{print $1/$2}'`
lgsn=`echo $lgmax $snmax | awk '{print $1/$2}'`
snpn=`echo $snmax $pnmax | awk '{print $1/$2}'`

# STEP-4b # TOTAL VECTOR AMPLITUDE RATIOS ################

tpn=`paste Pn_temp.Z.xy Pn_temp.R.xy Pn_temp.T.xy | awk '{print ((($2**2)+($4**2)+($6**2))**0.5)}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'`
tsn=`paste Sn_temp.Z.xy Sn_temp.R.xy Sn_temp.T.xy | awk '{print ((($2**2)+($4**2)+($6**2))**0.5)}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'`
tlg=`paste Lg_temp.Z.xy Lg_temp.R.xy Lg_temp.T.xy | awk '{print ((($2**2)+($4**2)+($6**2))**0.5)}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'`

# Calculating the VECTOR AMPLITUDE ratios
vlgpn=`echo $tlg $tpn | awk '{print $1/$2}'`
vlgsn=`echo $tlg $tsn | awk '{print $1/$2}'`
vsnpn=`echo $tsn $tpn | awk '{print $1/$2}'`


# STEP-4c # RMS AMPLITUDE RATIOS ##########################

# Calculating RMS amplitudes
rpn=`awk '{print $2**2}' Pn_temp.Z.xy | awk '{print $1**0.5}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'`
rsn=`awk '{print $2**2}' Sn_temp.T.xy | awk '{print $1**0.5}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'`
rlg=`awk '{print $2**2}' Lg_temp.Z.xy | awk '{print $1**0.5}' | awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'`

# Calculating the RMS AMPLITUDE ratios
rlgpn=`echo $rlg $rpn | awk '{print $1/$2}'`
rlgsn=`echo $rlg $rsn | awk '{print $1/$2}'`
rsnpn=`echo $rsn $rpn | awk '{print $1/$2}'`


# Writing the Output file
echo "$file $dist $lgpn $lgsn $snpn $vlgpn $vlgsn $vsnpn $rlgpn $rlgsn $rsnpn" | awk '{printf("%-30s %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)}' >> ${outfile}

# cleaning
rm -f sac.m
rm -f list1 temp.?.xy ??_temp.?.xy temp.? ??_temp.?


# Moving over to next file due to missing component
else
ls ${rfile}.${pcmp}Z ${rfile}.${pcmp}N ${rfile}.${pcmp}E
echo "One or more component missing. Moving to the next file..."
echo "${rfile}.${pcmp}Z missing component" >> log.AR

fi

a=`echo $a + 1 | bc`
done

# the end
#cd ..
#done
