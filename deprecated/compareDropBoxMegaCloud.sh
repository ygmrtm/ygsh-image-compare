#!/bin/bash

start=$(date +%s)
printf "========================================================================= %s\n" "$(date)"


workdirectory="/home/yg/Pictures/lnkDropboxCamera"
backupdirectory="/home/yg/Pictures/lnkMegaCamera"
cd "${workdirectory}"

files="$(find -L "$workdirectory" -type f \( -iname "*.jpg" \) )"
echo "$files" | while read filea; do
	matchPattern=$(echo $filea |  grep -v Duplicate)
	if [ "$matchPattern" != "" ]; then
		echo "==>Analizing... $filea"
		filesize=$(stat -c%s "$filea")
		filelsize=$((filesize - 100))
		fileusize=$((filesize + 100))
	    #echo "Size of $filea = $filesize bytes. Range: $filelsize-$fileusize"
		filesToCompare="$(find -L "$backupdirectory" -type f -name "*.jpg" -size +"$filelsize"c -size -"$fileusize"c)"
		duplicate=0
		if [ "$filesToCompare" != "" ]; then
			while read fileb; do
				echo "$filea vs $fileb"
				convert "$filea" /tmp/original.rgba
				convert "$fileb" /tmp/copy.rgba
				result=$(cmp /tmp/{original,copy}.rgba)
				if [ "$result" == "" ] && [ "$filea" != "$fileb" ]; then
					echo "This file is already in Mega Cloud "
					duplicate=1
				fi		
			done <<< "$filesToCompare" 
			rm /tmp/*.rgba
		fi
		#getting the name of the file
		renamedFile=$(echo ${filea##/*/} | sed 's/ /\ /g' )
		#echo $renamedFile is $duplicate
		if [ $duplicate -eq 1 ]; then
			mv "$filea" "${workdirectory}"/Duplicate_"$renamedFile"
		else
			echo "This file was in Dropbox and not in Mega... backuping it" 
			mv "$filea" $backupdirectory
		fi
	else
		echo "==>This file do not match the pattern $filea"
	fi

done	


printf "=========================================================================Total runtime: %d seconds\n" "$((`date '+%s'` - $start))"
printf "Depuring the Mega Cloud Directory... \n"
cd /home/yg/Dropbox/yg.mrtm/workspace/ygsh-image-compare 
./loopForDuplicateImages.sh /home/yg/Pictures /lnkMegaCloud >> /home/yg/Dropbox/yg.mrtm/workspace/logs/loopForDuplicateImages.log
printf "========================================================================= %d seconds\n" "$((`date '+%s'` - $start))"
