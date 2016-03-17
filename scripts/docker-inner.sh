#!/bin/sh
#
#
set -ex
bin="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

if [ "$#" -ne 4 ]; then
  echo "specify a channel, rpm dir, build num, and revision"
  exit 1
fi

channel=$1
rpm_dir=$2
build=$3
epoch=$4

if [ -n "$(git status --porcelain)" ]
    then
    echo >&2
    echo "Error: uncommitted changes present. Please commit to continue." >&2
    echo "Git commithash is included in rpm, so working tree must be clean to build." >&2
    exit 1
fi

fedora_release=$(rpm -q --queryformat '%{VERSION}\n' fedora-release)
GITSHA=$(git log -1 --format="%h")
name="wp-cli-0-$channel"

version=$(cat $bin/../VERSION.txt)
iteration=${epoch}.${GITSHA}
arch='x86_64'
url="https://github.com/pantheon-systems/${name}"
vendor='Pantheon'
description='wp-cli: Pantheon rpm containing commandline tool for WordPress'
install_prefix="/opt/pantheon/$name"

download_dir="$bin/../build"

rm -rf $download_dir
mkdir -p $download_dir
curl -L https://github.com/wp-cli/wp-cli/releases/download/v${version}/wp-cli-${version}.phar --output $download_dir/wp-cli-${version}.phar


fpm -s dir -t rpm  \
    --name "${name}" \
    --version "${version}" \
    --iteration "${iteration}" \
    --architecture "${arch}" \
    --url "${url}" \
    --vendor "${vendor}" \
    --description "${description}" \
    --prefix "$install_prefix" \
    -C build \
    wp-cli.phar


if [ ! -d "$rpm_dir/$fedora_release/wp-cli" ]  ; then
  mkdir -p $rpm_dir/$fedora_release/wp-cli
fi

mv *.rpm $rpm_dir/$fedora_release/wp-cli/

