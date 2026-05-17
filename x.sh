#!/bin/bash
ALL_FILES="/tmp/all_files_62826.txt"
while IFS= read -r filea; do
    echo "$filea"
done < "$ALL_FILES"