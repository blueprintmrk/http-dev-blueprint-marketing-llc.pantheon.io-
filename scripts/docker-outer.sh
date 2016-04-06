#!/bin/sh
set -e
bin="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
docker=$(which docker)

# Which fedora distros to build this rpm for
# wp-cli only runs on App servers; we do not have any
# app servers older than f22.
BUILD_VERSIONS=${BUILD_VERSIONS:-22}

echo "==> Running RPM builds for these Fedora version(s): $BUILD_VERSIONS"

RUN_ARGS="--rm"
if [ -n "$CIRCLECI"  ] ; then
  RUN_ARGS=""
fi

# set a default build -> 0 for when it doesn't exist
CIRCLE_BUILD_NUM=${CIRCLE_BUILD_NUM:-0}

# location to mount the source in the container
inner_mount="/src"

# epoch to use for -revision
epoch=$(date +%s)

case $CIRCLE_BRANCH in
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

rpm_dir=$inner_mount/pkg
if [ -d "$rpm_dir" ]  ; then
  rm -rf "$rpm_dir"
fi

for ver in $BUILD_VERSIONS; do
    echo "==> Building wp-cli rpm for fedora $ver "

    build_image=quay.io/getpantheon/rpmbuild-fedora:${ver}
    $docker pull $build_image

    exec_cmd="$inner_mount/scripts/docker-inner.sh $CHANNEL $rpm_dir $CIRCLE_BUILD_NUM $epoch"
    if [ -n "$BUILD_DEBUG" ] ; then
      RUN_ARGS="$RUN_ARGS -ti "
      exec_cmd="/bin/bash"
    fi

    read docker_cmd <<-EOL
      $docker run $RUN_ARGS \
        -e "build=$CIRCLE_BUILD_NUM" \
        -w $inner_mount \
        -v $bin/../:$inner_mount \
        $build_image $exec_cmd
EOL


    echo "Running: $docker_cmd"
    $docker_cmd
done
