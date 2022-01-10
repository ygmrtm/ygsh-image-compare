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
  exec 1>>"${logDir}"loopForDuplicateImages.log 2>&1
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
    echo "USAGE: ${0} /path/to/images/ folderToCheck "
    echo "   OR: ${0} /path/to/images/ folderToCheck --nolog"
    return 2;
  elif [ "$log_param" != "--nolog" ] && [ "$log_param" != "--enablelog" ]; then
    echo "Bad parameter for logs ${log_param}"
    return 2;
  fi
}

validExistingPath(){
  if  [ "$#" -ge 1 ] && [ "$#" -le 2 ]; then
    path="$1/$2"
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

getFileSize(){
  filesize=0
  filea=${1:-dummy_file}
  if [ -f "${filea}" ]; then
    machine=$(runningMachine)
    if  [[ "$machine" == "Mac" ]]; then
      # shellcheck disable=SC2046
      # shellcheck disable=SC2001
      # shellcheck disable=SC2005
      filesize=$(cut -d' ' -f1 <<<$(echo "$(wc -c "${filea}")" | sed -e 's/^[[:space:]]*//'))
    elif  [[ "$machine" == "Linux" ]]; then
      filesize=$(stat -c%s "$filea")
    else
      echo "$machine has not been implemented"
      exit 1
    fi
  fi
  echo "${filesize}"
}

convertImage(){
  if [ "$#" -eq 2 ]; then
    machine=$(runningMachine)
    if  [[ "$machine" == "Mac" ]]; then
      convert > /tmp/tmp.tmp;
      if [ $? -eq 127 ]; then
        brew install imagemagick@6;
      fi
      if [ -f "${1}" ]; then
        convert "$1" "$2"
      else
        echo "invalid file ${1}"
        return 2
      fi
    elif  [[ "$machine" == "Linux" ]]; then
      sudo dnf install ImageMagick
    else
      echo "$machine has not been implemented"
      exit 1
    fi
  else
    return 2
  fi
}

main(){
  if validUsage "${1}" "${2}" "${3}" && validExistingPath "${1}" "${2}"; then
    [[ "${log_param}" == "--enablelog" ]] && enableLogs || echo "${log_param}"
    start=$(date +%s)
    basedir=$1
    fotosdir=$2
    duplidir="/duplicateFotos_from_${fotosdir}"
    nospace_fotosdir="$(echo "${fotosdir}" | tr -d '[:space:]')"
    filedone="loopForDuplicateImages_${nospace_fotosdir}.done"

    printf "=================================================== %s\n" "$(date)"
    printf "Looking for duplicates images in %s%s \n" "${basedir}" "${fotosdir}"
    printf "Done File %s \n" "${filedone}"

    #files="$(find -L "$basedir$fotosdir" -type f \( -iname "*.jpg" ! -iname "*-WA*.jpg" \) )"
    files="$(find -L "$basedir$fotosdir" -type f \( -iname "*.jpg" \) )"
    totalfiles=$(echo -n "$files" | wc -l)
    echo "Count: $totalfiles"
    x=0
    echo "$files" | while read -r filea; do
      echo "----------------------------------------------------------------------"
      percent=$((((((x++))*100))/totalfiles))
      echo "$percent% $filea"
      if [ -f "${filea}" ]; then
        if [ -f "$logDir/$filedone" ]; then
          alreadyAnalized=$(grep "${filea}" "$logDir/$filedone")
        else
          alreadyAnalized=""
        fi
        if [ -z "$alreadyAnalized" ]; then
          filesize=$(getFileSize "${filea}")
          filelsize=$((filesize-100))
          fileusize=$((filesize+100))
          #echo "Size of $filea = $filesize bytes. Range: $filelsize-$fileusize"
          filesToCompare="$(find -L "$basedir$fotosdir" -type f -name *.jpg -size +"$filelsize"c -size -"$fileusize"c)"
          echo "$filesToCompare" | while read fileb; do
            convertImage "$filea" /tmp/original.rgba
            convertImage "$fileb" /tmp/copy.rgba
            result=$(cmp /tmp/{original,copy}.rgba)
            if [ "$result" == "" ] && [ "$filea" != "$fileb" ]; then
              if [ ! -d "$basedir$duplidir" ]; then
                echo "Creating Directory for duplicate Fotos.........."
                mkdir "$basedir$duplidir"
              fi
              echo "==>This file is Duplicated with $fileb"
              echo "Moving the file..."
              #getting the name of the file
              renamedFilePath=$(echo $filea | sed 's/ /\ /g' )
              renamedFile=$(echo ${filea##/*/} | sed 's/ /\ /g' )
              echo "$renamedFilePath" "$basedir$duplidir/$renamedFile"
              mv "$renamedFilePath" "$basedir$duplidir/$renamedFile"
              break
            fi
          done
          echo "$filea" >> "$logDir/$filedone"
        else
          echo "This file is already processed."
        fi
      else
        echo "It has already moved as a duplicate file"
      fi
      #exit 1;
    done
    rm /tmp/*.rgba
    printf "=================================================== Total runtime: %d seconds\n" "$((`date '+%s'` - $start))"
  else
    echo "Nothing to do..."
    exit 1
  fi
}

