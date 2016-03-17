#
# Build an RPM without docker, using native tools
#
bin="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
pkg_dir="$bin/../pkg"

# Which fedora distros to build this rpm for
# wp-cli only runs on App servers; we do not have any
# app servers older than f22.
BUILD_VERSIONS=${BUILD_VERSIONS:-22}

rm -rf "$pkg_dir"
mkdir -p "$pkg_dir"

# epoch to use for -revision
epoch=$(date +%s)

BRANCH=$(git rev-parse --abbrev-ref HEAD)
case $BRANCH in
"master")
  CHANNEL="release"
  ;;
"stage")
  CHANNEL="stage"
  ;;
"yolo")
  CHANNEL="yolo"
  ;;
*)
  CHANNEL="dev"
  ;;
esac

for fedora_release in $BUILD_VERSIONS; do
    $bin/docker-inner.sh $CHANNEL "$pkg_dir" 0 $epoch $fedora_release
done
