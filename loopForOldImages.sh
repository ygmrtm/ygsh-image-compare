#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>loopForOldImages.log 2>&1

if  [ "$#" -ne 2 ]; then
	echo "Bad number of parameters : $#"
	exit 1;
fi

start=$(date +%s)
printf "========================================================================= %s\n" "$(date)"
localdir=$1
remotedir=$2
# /home/yg/MEGA/yg.rwmind/ /media/yg/yg.deus/Lalo/yg.rwmind

printf "Looking for old images in $localdir \n"
printf "moving ... to $remotedir \n"

files="$(find -L "$localdir" -type f -mtime +730 )"
totalfiles=$(echo -n "$files" | wc -l)
echo "Count: $totalfiles"
x=0
echo "$files" | while read filea; do
	echo "----------------------------------------------------------------------"
	percent=$((((((x++))*100))/totalfiles))
	echo "$percent% $filea"

	filename="$(basename "$filea")"
  currentpath=${filea%$filename*}
  rootdir="yg.rwmind"
  newpath=${remotedir}${currentpath#*$rootdir}

  if [ -d "$newpath" ]; then
    ### Take action if $DIR exists ###
    echo "Ok for this path ${newpath}..."
  else
    ###  Control will jump here if $DIR does NOT exists ###
    echo "Error: ${newpath} not found."
    mkdir -p "${newpath}"
  fi
  echo "moving ${filea}" "${newpath}${filename}"
  mv -f "${filea}" "${newpath}${filename}"
done
find "$localdir" -depth -type d -empty
find "$localdir" -depth -type d -empty -delete
printf "=========================================================================Total runtime: %d seconds\n" "$((`date '+%s'` - $start))"