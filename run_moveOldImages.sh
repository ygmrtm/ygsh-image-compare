dir=$(cd "$(dirname "$0")" || exit; pwd)
source "${dir}"/moveOldImages.sh
######## Personal Cloud(Mega) - Keep 1 year
######## First Backup(Toshiba) last 8 years (yg.diabolus)
######## Last Backup (WD) 8+ years (terra)
main ~/"eduardo.sordo@gmail.com - Google Drive/My Drive/En cas que mori (requiescat in pace)/_Fotos_" ~/"MEGA2/yg.rwmind/Familia" 730 m
main ~/"eduardo.sordo@gmail.com - Google Drive/My Drive/En cas que mori (requiescat in pace)/_Fotos_" ~/"MEGA2/yg.rwmind/Familia" 300 c
main ~/"MEGA2/yg.rwmind" "/Volumes/yg.diabolus/yg.rwmind" 365 m
main ~/"MEGA2/yg.rwmind" "/Volumes/yg.diabolus/yg.rwmind" 300 c
main "/Volumes/yg.diabolus/yg.rwmind" "/Volumes/terra/Lalo/yg.rwmind" 2920 m
main "/Volumes/yg.diabolus/yg.rwmind" "/Volumes/terra/Lalo/yg.rwmind" 300 c

tar -cvzf /Volumes/terra/Lalo/cloudBkp/dropbox.tar.gz ~/Dropbox
tar -cvzf /Volumes/terra/Lalo/cloudBkp/mega.tar.gz ~/MEGA2

#tar -cvzf /Volumes/yg.deus/europa01.tar.gz /Volumes/terra/Lalo/yg.rwmind/EuropA/1.* > /dev/null &
#tar -cvzf /Volumes/yg.deus/europa02.tar.gz /Volumes/terra/Lalo/yg.rwmind/EuropA/2.* > /dev/null &
#tar -cvzf /Volumes/yg.deus/europa03.tar.gz /Volumes/terra/Lalo/yg.rwmind/EuropA/3.* > /dev/null &
#tar -cvzf /Volumes/yg.deus/europa04.tar.gz /Volumes/terra/Lalo/yg.rwmind/EuropA/4.* > /dev/null &
tar -cvzf /Volumes/yg.deus/europa05.tar.gz /Volumes/terra/Lalo/yg.rwmind/EuropA/5.* > /dev/null &
