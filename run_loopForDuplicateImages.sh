dir=$(cd "$(dirname "$0")" || exit; pwd)
# shellcheck disable=SC1090
source "${dir}"/loopForDuplicateImages.sh
main ~/MEGA/ "yg.rwmind"
main ~/Dropbox/ "Cargas de cámara"
main ~/Dropbox/ "WhatsApp Images"
main "/Volumes/GoogleDrive/My Drive/En cas que mori (requiescat in pace)/" "_Fotos_"
main "/Volumes/GoogleDrive/My Drive/Hijos de Chetumal/" "20221101 ChetuXcaMahaHolbBaca"