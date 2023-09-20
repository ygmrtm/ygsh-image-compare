#! /bin/bash

dir=$(cd "$(dirname "$0")" || exit; pwd)
logDir="${dir}/../logs/"

enableLogs(){
  if [ ! -d "$logDir" ]; then
    mkdir "$logDir"
    echo "logDir: ${logDir}"
  fi
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3
  exec 1>>"${logDir}"moveOldImages.log 2>&1
}

runningMachine(){
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=Mac;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
  echo "$machine"
}

validUsage(){
  log_param=${3:---enablelog}
  echo "[${1}][${2}][${log_param}]"
  if  [ "$#" -lt 2 ] || [ "$#" -gt 3 ] || [ -z "${1}" ] || [ -z "${2}" ]; then
    echo "Bad number of parameters : $#"
    echo "USAGE: ${0} /path/to/images/ /path/to/externalHD "
    echo "   OR: ${0} /path/to/images/ /path/to/externalHD --nolog"
    return 2;
  elif [ "$log_param" != "--nolog" ] && [ "$log_param" != "--enablelog" ]; then
    echo "Bad parameter for logs ${log_param}"
    return 2;
  fi
}

validExistingPath(){
  if  [ "$#" -eq 1 ]; then
    path="$1"
    if [ -d "$path" ]; then
      echo "Valid Path $(cd "$(dirname "$path")" || exit; pwd)/$(basename "$path")"
    else
      echo "Invalid Path $path"
      return 2;
    fi
  else
    echo "Bad number of parameters : $#"
    return 2
  fi
}
# /home/yg/MEGA/yg.rwmind/ /media/yg/yg.deus/Lalo/yg.rwmind
main(){
  if validUsage "${1}" "${2}" "${3}" && validExistingPath "${1}" && validExistingPath "${2}"; then
    [[ "${log_param}" == "--enablelog" ]] && enableLogs || echo "${log_param}"
    start=$(date +%s)
    localdir=$1
    remotedir=$2
    printf "=================================================== %s\n" "$(date)"
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
      newpath="${remotedir}${rootdir}${currentpath}"
      if [ -d "${newpath}" ]; then
        ### Take action if $DIR exists ###
        echo "Ok for this path ${newpath}..."
      else
        echo "${newpath} not found... creating it"
        mkdir -p "${newpath}"
      fi
      echo "moving ${filea}" "${newpath}${filename}"
      #mv -f "${filea}" "${newpath}${filename}"
      exit 1
    done
    #find "$localdir" -depth -type d -empty
    #find "$localdir" -depth -type d -empty -delete
    printf "=================================================== Total runtime: %d seconds\n" "$((`date '+%s'` - $start))"
  else
    echo "Nothing to do..."
    exit 1
  fi
}