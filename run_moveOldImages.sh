dir=$(cd "$(dirname "$0")" || exit; pwd)
source "${dir}"/moveOldImages.sh
#Family Cloud(GDrive) to Personal Cloud(Mega)
main ~/MEGA/yg.rwmind/ /Volumes/yg.deus/Lalo/yg.rwmind/
#Personal Cloud(Mega) to First Backup(Toshiba)
#main ~/MEGA/yg.rwmind/ /Volumes/yg.deus/Lalo/yg.rwmind/
#First Backup(Toshiba) to Last Backup (WD)
#main ~/MEGA/yg.rwmind/ /Volumes/yg.deus/Lalo/yg.rwmind/
