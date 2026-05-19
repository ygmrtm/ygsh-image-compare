# Implementation Plan - Selective Image Metadata Processing

The goal is to modify `procesador_imagenes.sh` so it only "adjusts" (clears metadata from) files that actually contain sensitive information (GPS coordinates or device model). If no such metadata is found, the file should remain untouched.

## User Review Required

> [!IMPORTANT]
> The definition of "sensitive metadata" is based on the tags currently being extracted by the script:
> - **Exiftool mode**: `GPSLatitude`, `GPSLongitude`, and `Model`.
> - **mdls mode**: `kMDItemLatitude`, `kMDItemLongitude`, and `kMDItemAcquisitionModel`.
>
> If any of these are present, the file will be cleaned. If none are present, the file will be skipped.

## Proposed Changes

### [MODIFY] [procesador_imagenes.sh](file:///Users/yg/Documents/GitHub/ygsh-image-compare/procesador_imagenes.sh)

#### 1. Fix File Discovery Loop
The current script uses `find ... > "$ALL_FILES"` and `read -r -d ''`. This is inconsistent because `find` outputs newlines by default, while `read -d ''` expects null terminators. This will be fixed to use `-print0`.

#### 2. Implement Metadata Check
- **In `exiftool` mode**: Use `exiftool -s -S` to check for the presence of the target tags.
- **In `mdls` mode**: Check if the returned values are not `(null)` or empty.
- Only execute the "cleaning" commands (`exiftool -all=`, `xattr -c`, `sips`) if sensitive data is found.

#### 3. Enhance Logging
Update the log messages to clearly state whether a file was "Adjusted" or "Skipped".

## Verification Plan

### Automated Tests
- Create test images with and without metadata.
- Run the script in both `exiftool` and `mdls` modes.
- Verify that only images with metadata have their modification times changed (or are reported as adjusted).

### Manual Verification
- Check `logs/metadatos_imagenes.log` to confirm skips and adjustments.
- Verify that `logs/metadatos_imagenes.csv` still contains the expected data for processed files.
