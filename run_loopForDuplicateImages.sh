dir=$(cd "$(dirname "$0")" || exit; pwd)
# shellcheck disable=SC1090
source "${dir}"/loopForDuplicateImages.sh
main ~/Dropbox/ "Cargas de cámara"
mv ~/Dropbox/Cargas\ de\ cámara/* ~/MEGA/Camera\ uploads/
main ~/MEGA/ "Camera uploads"
main ~/MEGA/ "yg.rwmind"