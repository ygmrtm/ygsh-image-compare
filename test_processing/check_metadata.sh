#!/bin/bash
FILE="$1"
# Exiftool check
# exiftool returns tags in format "Tag Name : Value"
# If no value, it might not print the tag or print nothing after the colon.
# Using -s -S to get just the value might be cleaner.
tags=$(exiftool -s -S -GPSLatitude -GPSLongitude -Model "$FILE")
if [ -n "$tags" ]; then
    echo "Exiftool: Sensitive metadata found"
    echo "$tags"
else
    echo "Exiftool: No sensitive metadata"
fi

# mdls check (MacOS only)
# mdls returns "(null)" if the attribute is missing.
mdls_data=$(mdls -name kMDItemLatitude -name kMDItemLongitude -name kMDItemAcquisitionModel "$FILE")
if echo "$mdls_data" | grep -qv "(null)"; then
    echo "mdls: Sensitive metadata found"
    echo "$mdls_data"
else
    echo "mdls: No sensitive metadata"
fi
