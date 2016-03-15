#!/bin/sh
# requires fpm (`gem install fpm`)

name='wp-cli'
install_prefix='/opt/wp0'
version=$(cat VERSION.txt)
# Iteration number holds a sequence number and the git commit hash.
# Circle builds:  "123.gitef8e0fb"
# Local builds:   "ts201503020102.gitef8e0fb"
iteration="${CIRCLE_BUILD_NUM:-ts$(date +%Y%m%d%H%M)}.git$(git rev-parse --short HEAD)"
arch='x86_64'
url='https://github.com/pantheon-systems/rpm-wp-cli'
vendor='Pantheon'
description='wp-cli.phar release from GitHub, bundled in an rpm for use on Pantheon'

if [ -n "$(git status --porcelain)" ]
    then
    echo >&2
    echo "Error: uncommitted changes present. Please commit to continue." >&2
    echo "Git commithash is included in rpm, so working tree must be clean to build." >&2
    exit 1
fi

rm -f wp-cli*.rpm

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
