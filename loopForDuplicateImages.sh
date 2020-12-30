#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>loopForDuplicateImages.log 2>&1


if  [ "$#" -ne 2 ]; then
	echo "Bad number of parameters : $#"
	exit 1;
fi

start=$(date +%s)
printf "========================================================================= %s\n" "$(date)"
basedir=$1
fotosdir=$2
#basedir="/home/yg/Documents/yg.mrtm"
#fotosdir="/tmpfotos"

printf "Looking for duplicates images in $basedir$fotosdir \n"
duplidir="/duplicateFotos"
filedone="loopForDuplicateImages.done"


#files="$(find -L "$basedir$fotosdir" -type f \( -iname "*.jpg" ! -iname "*-WA*.jpg" \) )"
files="$(find -L "$basedir$fotosdir" -type f \( -iname "*.jpg" \) )"
totalfiles=$(echo -n "$files" | wc -l)
echo "Count: $totalfiles"
x=0
echo "$files" | while read filea; do
	echo "----------------------------------------------------------------------"
	# shellcheck disable=SC1072
	percent=$((((((x++))*100))/totalfiles))
	echo "$percent% $filea"
	if [ -f "$filea" ]; then
		if [ -f "$filedone" ]; then
			alreadyAnalized=$(grep "$filea" "$filedone")
		else
			alreadyAnalized=""
		fi

		if [ -z "$alreadyAnalized" ]; then
			filesize=$(stat -c%s "$filea")
			filelsize=$((filesize-100))
			fileusize=$((filesize+100))
			#echo "Size of $filea = $filesize bytes. Range: $filelsize-$fileusize"
			filesToCompare="$(find -L "$basedir$fotosdir" -type f -name *.jpg -size +"$filelsize"c -size -"$fileusize"c)"
			echo "$filesToCompare" | while read fileb; do
        #install for fedora.... sudo dnf install ImageMagick
				convert "$filea" /tmp/original.rgba
				convert "$fileb" /tmp/copy.rgba
				result=$(cmp /tmp/{original,copy}.rgba)
				if [ "$result" == "" ] && [ "$filea" != "$fileb" ]; then
					if [ ! -d "$basedir$duplidir" ]; then
					  echo "Creating Directory for duplicate Fotos.........."
					  mkdir $basedir$duplidir
					fi
					echo "==>This file is Duplicated with $fileb"
					echo "Moving the file..."
					#getting the name of the file
					renamedFilePath=$(echo $filea | sed 's/ /\ /g' )
					renamedFile=$(echo ${filea##/*/} | sed 's/ /\ /g' )
					echo "$renamedFilePath" $basedir$duplidir/"$renamedFile"
					mv "$renamedFilePath" $basedir$duplidir/"$renamedFile"
					break
				fi		
			done
			echo "$filea" >> $filedone
		else
			echo "This file is already procesed."
		fi
	else
		echo "It has already moved as a duplicate file"
	fi
	#exit 1;
done
rm /tmp/*.rgba
printf "=========================================================================Total runtime: %d seconds\n" "$((`date '+%s'` - $start))"
