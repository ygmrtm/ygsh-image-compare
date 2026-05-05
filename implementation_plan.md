# Goal Description
Create a new shell script to identify and move duplicate images and videos within a given folder. The previous script relied on ImageMagick (`convert`), which caused library issues. The new script will use file hashing (like `shasum` or `md5`) to identify exact duplicates natively without relying on 3rd-party libraries. It will track processed files, compare file ages to preserve the older file, move the newer duplicate to a staging folder, and generate a report at the end.

## User Review Required
> [!IMPORTANT]
> **Duplicate Detection Strategy**: The proposed script will use **file hashing** (byte-for-byte comparison) to find exact duplicates. This means it will catch identical files perfectly and quickly, but it will *not* catch resized or visually similar but mathematically different images. Please confirm this exact-match approach is what you want.
> 
> **Staging Folder Location**: The plan is to create a `duplicates_staging` folder directly inside the input folder provided to the script. Is this location acceptable?

## Open Questions
> [!NOTE]
> 1. Do you want me to name the new script something specific (e.g., `find_duplicates.sh`) or overwrite the existing `loopForDuplicateImages.sh`?
> 2. Are there any specific video extensions you want to ensure are included beyond `.mp4`, `.mov`, `.avi`, `.mkv`?

## Proposed Changes

### Shell Script (New File)
#### [NEW] `find_duplicates.sh` (or name of your choice)
- **Input Validation**: Check that the input directory is provided and valid.
- **State Tracking**: Use a `.processed_files.log` in the script's `logs/` directory to track absolute paths (or hashes) of files already analyzed, so they are skipped in future runs.
- **File Iteration**: Find all images (`.jpg`, `.jpeg`, `.png`, `.gif`, `.heic`) and videos (`.mp4`, `.mov`, `.avi`, `.mkv`) in the input folder.
- **Duplicate Logic**: 
  - Compute the file hash (e.g., `md5`).
  - If a hash is seen for the first time, store it.
  - If a hash is already in our stored list, it's a duplicate.
- **Age Comparison**: 
  - Compare the modification times (using `stat`).
  - Keep the older file in its place.
  - Move the newer file to the `duplicates_staging` folder.
- **Logging**: Write to `logs/moved_duplicates.log` with the timestamp, the original file, and the moved file.
- **Report**: Print a summary report at the end showing: Total files scanned, files skipped (already processed), duplicates found, and files moved.

## Verification Plan

### Manual Verification
1. Run the script on a test folder containing known duplicate images and videos.
2. Verify the newer duplicates are moved to the staging folder.
3. Verify the older files remain intact.
4. Run the script a second time on the same folder to verify it skips already processed files and finishes quickly.
5. Check `logs/moved_duplicates.log` for correct logging entries.
