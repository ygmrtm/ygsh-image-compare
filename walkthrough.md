# Duplicate Images & Videos Script Implementation

I have successfully created the new `find_duplicates.sh` script and deprecated the old one. The new approach is significantly faster and more robust as it uses built-in hashing tools instead of relying on external libraries like ImageMagick.

## Changes Made

### 1. New Script Created
#### [NEW] [find_duplicates.sh](file:///Users/yg/Documents/GitHub/ygsh-image-compare/find_duplicates.sh)
- **Hash-based Exact Matching**: Uses `md5` (Mac) or `md5sum` (Linux) to find exact duplicate files.
- **Support for Media**: Includes images (`.jpg`, `.jpeg`, `.png`, `.gif`, `.heic`) and videos (`.mp4`, `.mov`, `.avi`, `.mkv`).
- **Timestamp Comparison**: Utilizes `stat` to check the file modification times. The older file is preserved in its original location, and the newer file is moved.
- **Staging Folder**: Automatically creates a `duplicates_staging` folder one level up from the provided input folder.
- **State Tracking**: Maintains a list of already processed files in `logs/processed_files.log` to significantly speed up subsequent runs by skipping them.
- **Move Log**: Logs all move actions with timestamps in `logs/moved_duplicates.log`.
- **Reporting**: Prints a clear summary report at the end showing files scanned, skipped, and moved.

### 2. Old Script Deprecated
#### [MODIFY] [loopForDuplicateImages.sh](file:///Users/yg/Documents/GitHub/ygsh-image-compare/loopForDuplicateImages.sh)
- Added an early `exit 1` with a deprecation notice informing users to use the new `find_duplicates.sh` script instead.

## How to use

Run the script by passing the folder you want to scan:
```bash
./find_duplicates.sh /path/to/your/input_folder
```

### What to expect
- The script will calculate the hashes of the files and show a percentage progress.
- Duplicates will be moved to `/path/to/your/duplicates_staging` (one level above `input_folder`).
- Logs are kept inside the `logs/` folder next to the script itself.
- You can safely re-run the script on the same folder—it will remember what it already processed and skip those files!
