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
  log_param=${5:---enablelog}
  echo "[${1}][${2}][${3}][${4}][${log_param}]"
  if  [ "$#" -lt 4 ] || [ "$#" -gt 5 ] || [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then
    echo "Bad number of parameters : $#"
    echo "USAGE: ${0} /path/to/images/ /path/to/externalHD backDays [c|m]"
    echo "   OR: ${0} /path/to/images/ /path/to/externalHD backDays [c|m] --nolog"
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

#Delete the shortest match of string in $var from the beginning:
#${var#string}
#Delete the longest match of string in $var from the beginning:
#${var##string}
#Delete the shortest match of string in $var from the end:
#${var%string}
#Delete the longest match of string in $var from the end:
#${var%%string}
main(){
  if validUsage "${1}" "${2}" "${3}" "${4}" "${5}" && validExistingPath "${1}" && validExistingPath "${2}"; then
    [[ "${log_param}" == "--enablelog" ]] && enableLogs || echo "${log_param}"
    start=$(date +%s)
    localdir=$1
    remotedir=$2
    daysback=$3
    copymove=$4
    printf "=================================================== %s\n" "$(date)"
    printf "Looking for old images in $localdir \n"
    printf "destination $remotedir \n"
    if [[ "c" == "${copymove}" ]]; then
      files="$(find -L "$localdir" -type f -mtime -$daysback ! -path "*/.*" -prune )"
    elif [[ "m" == "${copymove}" ]]; then
      files="$(find -L "$localdir" -type f -mtime +$daysback )"
    fi

    totalfiles=$(echo -n "$files" | wc -l)
    echo "Count: $totalfiles"
    # shellcheck disable=SC1073
    x=0
    if [[ ${totalfiles} -gt 1 ]]; then
      echo "$files" | while read filea; do
        echo "----------------------------------------------------------------------"
        percent=$((((((x++))*100))/totalfiles))
        echo "$percent% $filea"
        last10=${localdir:(-10)}
        filename="$(basename "$filea")"
        temp=${filea%$filename*}
        currentpath=${temp#*$last10*}
        newpath="${remotedir}${currentpath}"
        if [ -d "${newpath}" ]; then
          ### Take action if $DIR exists ###
          echo "Ok for this path ${newpath}"
        else
          echo "${newpath} not found... creating it"
          mkdir -p "${newpath}"
        fi
        if [[ "c" == "${copymove}" ]]; then
          echo "copying ${filea}" "${newpath}${filename}"
          cp -f "${filea}" "${newpath}${filename}"
        elif [[ "m" == "${copymove}" ]]; then
          echo "moving ${filea}" "${newpath}${filename}"
          mv -f "${filea}" "${newpath}${filename}"
        else
          echo "Bad Option"
        fi

        #break
      done
      find "$localdir" -depth -type d -empty
      find "$localdir" -depth -type d -empty -delete
    fi
    printf "=================================================== Total runtime: %d seconds\n" "$((`date '+%s'` - $start))"
  else
    echo "Nothing to do..."
    exit 1
  fi
  echo "\n\n"
}