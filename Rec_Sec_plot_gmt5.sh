#!/bin/bash
#	script name: Rec_Sec_plot_gmt5.sh (SELF SCALED AS in SAC)

# Initializing
#rm -f tmp depmaxlist
cd /DATA/Lg_Work/EGU_2021/tomography/Q_Tomo/data_15_deg_tolerance/events/2018193194647/RMKT-SUND

echo "RS_list.txt of files for Record Section Plot"
echo
echo "Will contain file names as follows"
echo "**********************************"
echo "v_2011261124051_ER_MOHN.BHZ"
echo "v_2011261124051_IM_DGPR.BHZ"
echo "v_2011261124051_IM_JBP.HHZ"
echo "**********************************"
echo
#ls *.txt
echo
#echo "Input the list of files to use for Record Section Plot (eg. RS_list.txt)"
#read list
list=z_files.txt
# Getting root name (file name before the .txt) to write the output
rootnm=`ls $list | awk -F. '{print $1}'`

echo "Input start time of the Record Section"
read stime

echo "Input end time of the Record Section"
read etime

#echo "Input the length of time in seconds for which record section has to be plotted (eg. 100/500/1000)"
#read time

echo "Input the scale for amplification of the trace (eg. 100/200/1000 etc.)"
read scale

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
#echo "Filtering between $lco and $uco with two poles and two passes"

n=`wc -l $list | awk '{print $1}'`
a=1
while [ $a -le $n ]
do
echo "Extracting line $a from file $list"
file=`awk 'NR==num {print $1}' num="$a" $list`

#echo "echo on" > sac.m
#echo "r $file" >> sac.m
#echo "rtr" >> sac.m
#echo "rmean" >> sac.m
#echo "bp co $lco $uco p 2 n 2" >> sac.m
#echo "w test" >> sac.m
#echo "q" >> sac.m
# running sac macro
#sac sac.m

sac<<!
r $file
rtr
rmean
bp co 0.5 5.0 p 2 n 4
w test
q
!


# Getting the max amplitude of the filtered waveform for self-scaling later (as done in SAC) NOTE: THIS IS ONLY APPLIED TO FILTERED DATA
depmax=`saclhdr -DEPMAX test`
echo "$depmax" >> depmaxlist

# Creating the xy file sequentially
#ls $test > list1
#sac2xy < list1
#mv test.xy ${file}.xy
sac2xy test test.xy
mv test.xy ${file}.xy


# cleaning
#rm -f test sac.m list1
rm -f test

a=`echo $a + 1 | bc`
done

# Getting the largest value of amplitude from all filtered waveform to be used for self-scaling later (as done in SAC)
maxa=`sort -g -k1 depmaxlist | tail -1`


#elif [ $ans = "N" ] || [ $ans = "n" ] ; then
#echo "Continuing without filtering"
#lco=x
#uco=x

# Creating the xy file all together
# I think, sac2xy does not work in this way. It requires input sac file and output name, it has to be given individually for each file.
#sac2xy < $list

#else
#echo "Answer should have been Y or N. Quitting..."
#exit

#fi
############################### FILTERING OVER ##########################


# getting the event name from the first file in the list to write on top of the plot
event=`head -1 $list | awk -F_ '{print $2}'`

# Running through the files in the list to get distance from sac header and writing the input file for plotting
n=`wc -l $list | awk '{print $1}'`
a=1
while [ $a -le $n ]
do
echo "Extracting line $a from file $list"
file=`awk 'NR==num {print $1}' num="$a" $list`
# Distance extraction
dist=`saclhdr -DIST $file`
sta=`saclhdr -KSTNM $file`
cmp=`saclhdr -KCMPNM $file | cut -c3`

echo "File name $file Distance $dist Station $sta Component $cmp"
echo

# Writing the input file for plotting
# With self scaling (like in SAC) using the max amplitude of all traces
cat ${file}.xy | awk '{if ($1>=st && $1<=et) print $1, d, ($2*s)/ma}' st="$stime" et="$etime" d="$dist" s="$scale" ma="$maxa" > ${sta}_t_d_a.${cmp}
# Without self-scaling
#cat ${file}.xy | awk '{if ($1>=st && $1<=et) print $1, d, $2*s}' st="$stime" et="$etime" d="$dist" s="$scale" > ${sta}_t_d_a.${cmp}

# Writing the filename and distance values to a file for use later
echo "${sta}_t_d_a.${cmp} $dist" >> tmp

a=`echo $a + 1 | bc`
done


############ GMT ########################3
# setting output file
out=PRS_bp${lco}-${uco}Hz_${rootnm}_${event}
echo "Output file is ${out}.ps"

# Setting the bounds on plot for distance
dpad=`sort -g -k2 tmp | sed -n -e '1p;$p' | awk '{printf" " $2}' |awk '{printf("%.0f\n", ($2-$1)/20)}'`
#mind=`sort -g -k2 tmp | head -1 | awk '{print $2-dp}' dp="$dpad"`
#maxd=`sort -g -k2 tmp | tail -1 | awk '{print $2+dp}' dp="$dpad"`
mind=500
maxd=750
#bounds="-R${stime}/${etime}/${mind}/${maxd}"
bounds="-R${stime}/${etime}/${mind}/${maxd}"
echo "Bounds are $bounds"

# Calculating travel times of seismic phases
## P-wave with Vp=6.5 km/s
#spt=`echo $mind | awk '{print $1/6.5}'`
#ept=`echo $maxd | awk '{print $1/6.5}'`
# S-wave with Vs=3.76 km/s (using Vp/Vs=1.73)
#sst=`echo $mind | awk '{print $1/3.76}'`
#est=`echo $maxd | awk '{print $1/3.76}'`
# Pn with Vpn=8.1 km/s
ubspnt=`echo $mind | awk '{print $1/8.1}'`
ubepnt=`echo $maxd | awk '{print $1/8.1}'`
lbspnt=`echo $mind | awk '{print $1/7.7}'`
lbepnt=`echo $maxd | awk '{print $1/7.7}'`
# Sn with Vsn=4.6 km/s
ubssnt=`echo $mind | awk '{print $1/4.6}'`
ubesnt=`echo $maxd | awk '{print $1/4.6}'`
lbssnt=`echo $mind | awk '{print $1/4.2}'`
lbesnt=`echo $maxd | awk '{print $1/4.2}'`
# Lg-wave window 3.6 to 2.8 km/s
ubslgt=`echo $mind | awk '{print $1/3.6}'`
ubelgt=`echo $maxd | awk '{print $1/3.6}'`
lbslgt=`echo $mind | awk '{print $1/2.8}'`
lbelgt=`echo $maxd | awk '{print $1/2.8}'`

#gmt gmtset ANOT_OFFSET = 0.200i
gmt gmtset PS_MEDIA a4

#cat data_baz_rfn | awk '{print $1,$2,$3}'  > datar
#cat data_baz_rfn | awk '{print $1,$2,$4}'  > datat
proj=-JX9.0i/6.0i

gmt psbasemap $proj $bounds -Ba100f10:"Time(s)":/f20a100:"Distance(km)":\SWen -K > ${out}.ps

# Running through the input files and plotting the wiggle
cat tmp > fish1

while [  -s fish1 ]; do

        line=`head -1 fish1`
        tail -n +2 fish1 > fish2
        cat fish2 > fish1
        rm -f fish2

echo "line is $line"
infile=`echo $line | awk '{print $1}'`
# Text distance and time for plotting the station name on the trace
tdist=`echo $line | awk '{print $2+10}'`
ttime=`echo $stime | awk '{print $1+10}'`
sta=`echo $line | awk '{print $1}' | awk -F_ '{print $1}'`

# Plotting the wiggle
gmt pswiggle ${infile} $proj $bounds -Z1 -B -W0.5p,0/0/0 -K -O >> ${out}.ps

# Writing the station name
#echo "0.5 5.4 23 0 5 CM 2011261124051" |
gmt pstext -V -R -JX -N -F+f12,Times-Roman+jLB -O -K << EOF >> ${out}.ps
$ttime $tdist $sta
EOF

#gmt psxy $FRAME $BOX -W1p,0/0/0 -O -K <<END >> ${out}.ps
#0 -10
#0 380
#END

done

# Plotting Pn arrival window as red dashed lines
gmt psxy $proj $bounds -B -O -K -W1p,255/0/0,- << EOF1 >> ${out}.ps
$ubspnt $mind
$ubepnt $maxd
EOF1
gmt psxy $proj $bounds -B -O -K -W1p,255/0/0,- << EOF2 >> ${out}.ps
$lbspnt $mind
$lbepnt $maxd
EOF2


# Plotting Sn arrival as blue dashed lines
gmt psxy $proj $bounds -B -O -K -W1p,0/0/255,- << EOF3 >> ${out}.ps
$ubssnt $mind
$ubesnt $maxd
EOF3
gmt psxy $proj $bounds -B -O -K -W1p,0/0/255,- << EOF4 >> ${out}.ps
$lbssnt $mind
$lbesnt $maxd
EOF4


# Plotting Lg window as green dashed lines
gmt psxy $proj $bounds -B -O -K -W1p,0/255/0,- << EOF5 >> ${out}.ps
$ubslgt $mind
$ubelgt $maxd
EOF5

gmt psxy $proj $bounds -B -O -K -W1p,0/255/0,- << EOF6 >> ${out}.ps
$lbslgt $mind
$lbelgt $maxd
EOF6

# Writing the text using label dist and label time
ldist=`echo $maxd | awk '{print $1+dp}' dp="$dpad"`
ltime=`echo $etime | awk '{print $1-10}'`
gmt pstext -V -R -JX -N -F+f14,Times-Roman+jRB -O -K << EOF7 >> ${out}.ps
$ltime $ldist "$list" ($event) f = $lco - $uco Hz
EOF7

# end of plot
gmt psxy ${proj} ${bounds} -O < /dev/null >> ${out}.ps

# Plotting
gv ${out}.ps


# cleaning up
#rm -f stack.r stack.t stack.r.a stack.t.a stack.t_?? stack.r_?? temp1 stacklist.r stacklist.t
#rm -f ${sta}_T_D_A.r ${sta}_T_D_A.t
#rm -f .gmtcommands4 .gmtdefaults4
rm -f gmt.history gmt.conf tmp fish1 *.xy *_t_d_a.?  depmaxlist
echo " ...... finished "
# the end
