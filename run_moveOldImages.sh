dir=$(cd "$(dirname "$0")" || exit; pwd)
source "${dir}"/moveOldImages.sh
######## Personal Cloud(Mega) - Keep 1 year
######## First Backup(Toshiba) last 8 years
######## Last Backup (WD) 8+ years
main ~/"Google Drive/My Drive/En cas que mori (requiescat in pace)/_Fotos_" ~/"MEGA/yg.rwmind/Familia" 730 m
main ~/"Google Drive/My Drive/En cas que mori (requiescat in pace)/_Fotos_" ~/"MEGA/yg.rwmind/Familia" 300 c
main ~/"MEGA/yg.rwmind" "/Volumes/yg.diabolus/yg.rwmind" 365 m
main ~/"MEGA/yg.rwmind" "/Volumes/yg.diabolus/yg.rwmind" 300 c
main "/Volumes/yg.diabolus/yg.rwmind" "/Volumes/terra/Lalo/yg.rwmind" 2920 m
main "/Volumes/yg.diabolus/yg.rwmind" "/Volumes/terra/Lalo/yg.rwmind" 300 c

tar -cvzf /Volumes/terra/Lalo/cloudBkp/dropbox.tar.gz ~/Dropbox
tar -cvzf /Volumes/terra/Lalo/cloudBkp/mega.tar.gz ~/MEGA