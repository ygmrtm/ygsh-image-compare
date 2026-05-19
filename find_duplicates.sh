#!/bin/bash

echo "Starting duplicate check..."

validUsage() {
  if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_folder>"
    exit 1
  fi
  if [ ! -d "$1" ]; then
    echo "Error: Directory $1 does not exist."
    exit 1
  fi
}

runningMachine(){
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=Mac;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
  echo "$machine"
}

getFileTime() {
  machine=$(runningMachine)
  if [[ "$machine" == "Mac" ]]; then
    stat -f "%m" "$1"
  else
    stat -c "%Y" "$1"
  fi
}

getFileHash() {
  machine=$(runningMachine)
  if [[ "$machine" == "Mac" ]]; then
    md5 -q "$1"
  else
    md5sum "$1" | awk '{print $1}'
  fi
}

main() {
  validUsage "$1"

  # Convert relative path to absolute
  INPUT_FOLDER=$(cd "$1" || exit; pwd)
  
  # Staging folder is one level up
  STAGING_FOLDER="$(dirname "$INPUT_FOLDER")/duplicates_staging"
  
  # Script directory for logs
  SCRIPT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
  LOGS_DIR="$SCRIPT_DIR/logs"
  PROCESSED_LOG="$LOGS_DIR/processed_files.log"
  MOVED_LOG="$LOGS_DIR/moved_duplicates.log"
  
  mkdir -p "$STAGING_FOLDER"
  mkdir -p "$LOGS_DIR"
  touch "$PROCESSED_LOG"
  
  start=$(date +%s)
  printf "=================================================== %s\n" "$(date)"
  printf "Input folder: %s\n" "$INPUT_FOLDER"
  printf "Staging folder: %s\n" "$STAGING_FOLDER"
  
  # Temp files
  ALL_FILES="/tmp/all_files_$$.txt"
  FILES_TO_PROCESS="/tmp/files_to_process_$$.txt"
  HASH_DICT="/tmp/hash_dict_$$"
  
  mkdir -p "$HASH_DICT"
  
  # Find all images and videos
  find -L "$INPUT_FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.heic" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" \) > "$ALL_FILES"
  
  total_files_found=$(wc -l < "$ALL_FILES" | tr -d ' ')
  echo "Files Found: $total_files_found"
  if [ "$total_files_found" -eq 0 ]; then
    echo "No media files found in $INPUT_FOLDER"
    rm -f "$ALL_FILES"
    rm -rf "$HASH_DICT"
    exit 0
  fi
  
  # Filter out processed files
  if [ -s "$PROCESSED_LOG" ]; then
    grep -F -v -f "$PROCESSED_LOG" "$ALL_FILES" > "$FILES_TO_PROCESS" 2>/dev/null || cat "$ALL_FILES" > "$FILES_TO_PROCESS"
  else
    cat "$ALL_FILES" > "$FILES_TO_PROCESS"
  fi
  
  total_to_process=$(wc -l < "$FILES_TO_PROCESS" | tr -d ' ')
  skipped_files=$((total_files_found - total_to_process))
  
  echo "Found $total_files_found total media files."
  echo "Skipping $skipped_files already processed files."
  echo "Processing $total_to_process files..."
  
  x=0
  duplicates_found=0
  
  while IFS= read -r filea; do
    [ -z "$filea" ] && continue
    
    x=$((x + 1))
    percent=$(( x * 100 / total_to_process ))
    echo "----------------------------------------------------------------------"
    echo "$percent% [$x/$total_to_process] $filea"
    
    file_hash=$(getFileHash "$filea")
    
    if [ -f "$HASH_DICT/$file_hash" ]; then
      duplicates_found=$((duplicates_found + 1))
      existing_file=$(cat "$HASH_DICT/$file_hash")
      
      echo "==> DUPLICATE FOUND!"
      echo "File 1: $existing_file"
      echo "File 2: $filea"
      
      time1=$(getFileTime "$existing_file")
      time2=$(getFileTime "$filea")
      
      if [ "$time1" -le "$time2" ]; then
        file_to_keep="$existing_file"
        file_to_move="$filea"
      else
        file_to_keep="$filea"
        file_to_move="$existing_file"
        # Update the dict to point to the kept file
        echo "$file_to_keep" > "$HASH_DICT/$file_hash"
      fi
      
      echo "Keeping older: $file_to_keep"
      echo "Moving newer:  $file_to_move"
      
      filename=$(basename "$file_to_move")
      # Handle name collisions in staging folder
      dest_path="$STAGING_FOLDER/$filename"
      counter=1
      while [ -e "$dest_path" ]; do
        name="${filename%.*}"
        ext="${filename##*.}"
        dest_path="$STAGING_FOLDER/${name}_copy${counter}.${ext}"
        counter=$((counter + 1))
      done
      
      mv "$file_to_move" "$dest_path"
      echo "[$(date)] MOVED: $file_to_move -> $dest_path" >> "$MOVED_LOG"
      
      # Mark both as processed
      echo "$file_to_keep" >> "$PROCESSED_LOG"
      echo "$file_to_move" >> "$PROCESSED_LOG"
    else
      # Not a duplicate yet, add to hash dict
      echo "$filea" > "$HASH_DICT/$file_hash"
      # Mark as processed
      echo "$filea" >> "$PROCESSED_LOG"
    fi
  done < "$FILES_TO_PROCESS"
  
  # Cleanup temp files
  rm -f "$ALL_FILES" "$FILES_TO_PROCESS"
  rm -rf "$HASH_DICT"
  
  printf "===================================================\n"
  printf "REPORT\n"
  printf "Total runtime: %d seconds\n" "$(( $(date '+%s') - start ))"
  printf "Total files scanned: %d\n" "$total_files_found"
  printf "Files skipped (already processed): %d\n" "$skipped_files"
  printf "Duplicates found and moved: %d\n" "$duplicates_found"
  printf "Staging folder: %s\n" "$STAGING_FOLDER"
  printf "Done at: %s\n" "$(date)"
  printf "===================================================\n"
}

main "$@"
