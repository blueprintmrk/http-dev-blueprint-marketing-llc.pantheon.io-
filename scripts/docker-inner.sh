#!/bin/sh
#
#
set -ex
bin="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 channel rpm_dir build_num epoch [fedora_release]"
  exit 1
fi

if [ -n "$(git status --porcelain)" ]
    then
    echo >&2
    echo "Error: uncommitted changes present. Please commit to continue." >&2
    echo "Git commithash is included in rpm, so working tree must be clean to build." >&2
    exit 1
fi

channel=$1
rpm_dir=$2
build=$3
epoch=$4
fedora_release=$5
if [ -z "$fedora_release" ]
then
    fedora_release=$(rpm -q --queryformat '%{VERSION}\n' fedora-release)
fi

GITSHA=$(git log -1 --format="%h")
shortname="wp-cli-0.x"
name="$shortname-$channel"

version=$(cat $bin/../VERSION.txt)
iteration=${epoch}.${GITSHA}
arch='x86_64'
url="https://github.com/pantheon-systems/${shortname}"
vendor='Pantheon'
description='wp-cli: Pantheon rpm containing commandline tool for WordPress'
install_prefix="/opt/pantheon/$shortname"

download_dir="$bin/../build"

rm -rf $download_dir
mkdir -p $download_dir
curl -L https://github.com/wp-cli/wp-cli/releases/download/v${version}/wp-cli-${version}.phar --output $download_dir/wp-cli.phar


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

