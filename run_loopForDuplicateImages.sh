dir=$(cd "$(dirname "$0")" || exit; pwd)
# shellcheck disable=SC1090
source "${dir}"/loopForDuplicateImages.sh
main ~/Dropbox/ "Cargas de cámara"
mv ~/Dropbox/Cargas\ de\ cámara/* ~/MEGA2/Camera\ uploads/
main ~/MEGA2/ "Camera uploads"
main ~/MEGA2/ "yg.rwmind"