dir=$(cd "$(dirname "$0")" || exit; pwd)
source "${dir}"/moveOldImages.sh
######## Personal Cloud(Mega) - Keep 1 year
######## First Backup(Toshiba) last 8 years
######## Last Backup (WD) 8+ years
main ~/"MEGA/yg.rwmind" "/Volumes/yg.diabolus/yg.rwmind" 365 m
main ~/"Google Drive/My Drive/En cas que mori (requiescat in pace)/_Fotos_" "/Volumes/yg.diabolus/yg.rwmind/Familia" 730 m
main "/Volumes/yg.diabolus/yg.rwmind" "/Volumes/terra/Lalo/yg.rwmind" 2920 m
main "/Volumes/yg.diabolus/yg.rwmind" "/Volumes/terra/Lalo/yg.rwmind" 365 c
main ~/"Google Drive/My Drive/En cas que mori (requiescat in pace)/_Fotos_" ~/"MEGA/yg.rwmind/Familia" 365 c