# 📸 The One True Image Comparison Suite 💍

Welcome to the over-engineered, painstakingly artisanal, handcrafted-in-bash image comparison suite for macOS. 

If you have duplicate images scattered across your drive and a profound disregard for GUI applications, you've come to the right place. We've got scripts. Lots of them.

## 🚀 How to Use (If You Dare)

There is a master script. It's called the "One Ring to rule them all". Just run it and hope for the best:

```bash
./master_workflow.sh
```

It will execute the following in a glorious, potentially destructive cascade (don't worry, we added backups because we are not complete savages):
1. **Find Duplicates** (`run_find_duplicates.sh`): Sniffs out your exact copies.
2. **Move Old Images** (`run_move_old_Images.sh`): Banishes the older duplicates to a staging area.
3. **Process Images** (`run_procesador_imagenes.sh`): Strips sensitive metadata (GPS, etc.) so you can post them online without doxxing yourself.

## 🚨 Prerequisites
- **macOS**: This is built for macOS. If you're on Windows or Linux, we're sorry for your loss.
- **exiftool**: Optional but recommended. If you don't have it, the script will politely try to install Homebrew and `exiftool` for you. 

## 🤡 Disclaimers
- "If any of them fail, should not continue with the next one" - Yes, we implemented this. We aren't monsters.
- Backups for processed images are securely tucked away one directory above your input folder. So if you mess up, you only have yourself to blame.
- By running this, you agree that reading shell scripts builds character.

Enjoy.
