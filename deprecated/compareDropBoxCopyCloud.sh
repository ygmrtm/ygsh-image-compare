#!/bin/bash

start=$(date +%s)
printf "========================================================================= %s\n" "$(date)"


workdirectory="/home/yg/Pictures/lnkDropboxCamera"
backupdirectory="/home/yg/Pictures/lnkMegaCamera"
cd "${workdirectory}"

for f in *.jpg 
do
	matchPattern=$(echo $f |  grep '^[0-9]*-[0-9]*-[0-9]* [0-9]*\.[0-9]*\.[0-9]*\.jpg$' )
	if [ "$matchPattern" != "" ]; then
		echo "==>Analizing... $f"
		date=$(echo $f | cut -d' ' -f1) 
		hour=$(echo $f | cut -d' ' -f2) 
		year=$(echo $date | cut -d'-' -f1)
		month=$(echo $date | cut -d'-' -f2)
		day=$(echo $date | cut -d'-' -f3)
		hours=$(echo $hour | cut -d'.' -f1)
		minutes=$(echo $hour | cut -d'.' -f2)
		seconds=$(echo $hour | cut -d'.' -f3)
		cp $backupdirectory/IMG_$year$month${day}_$hours$minutes* .
		convert $date\ $hour original.rgba
		duplicate=0
		for g in IMG_*.*
		do if [ "$g" != "IMG_*.*" ]; then
			convert $g copy.rgba
			result=$(cmp {original,copy}.rgba)
			if [ "$result" == "" ]; then
				echo "File $f is already backup"
				duplicate=1;
			fi
		fi done 
		if [ $duplicate -eq 0 ]; then
			echo "mv $date\ $hour $backupdirectory/IMG_$year$month${day}_$hours$minutes$seconds.jpg"
			echo "This file was in Dropbox and not in Copy... backuping it" 
			mv $date\ $hour $backupdirectory/IMG_$year$month${day}_$hours$minutes$seconds.jpg
		else
			mv $date\ $hour Duplicate_$date\ $hour
		fi
		rm *.rgba
		rm IMG_*.*
	else
		echo "==>This file do not match the pattern $f"
	fi

done	


printf "=========================================================================Total runtime: %d seconds\n" "$((`date '+%s'` - $start))"
printf "Depuring the Mega Cloud Directory... \n"
#cd /home/yg/Dropbox/yg.mrtm/workspace/sh
#./loopForDuplicateImages.sh /home/yg/Pictures /lnkMegaCloud >> /home/yg/Dropbox/yg.mrtm/workspace/logs/loopForDuplicateImages.log
printf "========================================================================= %d seconds\n" "$((`date '+%s'` - $start))"
