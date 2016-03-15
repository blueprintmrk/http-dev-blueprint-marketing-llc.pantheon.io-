# Read the version we are packaging from VERSION.txt
VERSION := $(shell cat VERSION.txt)

.PHONY: all
all:  deps rpm

.PHONY: deps
deps: fpm_deps

.PHONY: rate_limit
rate_limit:
	curl -H "Authorization: token $$GITHUB_TOKEN" -XGET https://api.github.com/rate_limit

.PHONY: validate_circle
validate_circle:
	ruby -r yaml -e 'puts YAML.dump(STDIN.read)' < circle.yml

build/wp-cli.phar:
	[ -d build ] && rm -rf build
	-mkdir -p build
	wget https://github.com/wp-cli/wp-cli/releases/download/v$(VERSION)/wp-cli-$(VERSION).phar --output-document=$@

.PHONY: fpm_deps
fpm_deps:
	-which rpm &>/dev/null || (which apt-get &>/dev/null && sudo apt-get install rpm)
	-which rpm &>/dev/null || (which brew &>/dev/null && brew install rpm)
	-which fpm &>/dev/null || gem install fpm

.PHONY: package_cloud_deps
package_cloud_deps:
	which package_cloud &>/dev/null || gem install package_cloud

.PHONY: rpm
rpm: fpm_deps build/wp-cli.phar
	sh build-rpm.sh

# for now only stage gets the artifact deplooys, as I see this being the inevitable default target.
# prod deploy should be replaced with a service/trigger from slack
.PHONY: stage_deploy
stage_deploy: package_cloud_deps rpm pkgcloud_stage
.PHONY: pkgcloud_stage
pkgcloud_stage:
	bash deploy/push_packagecloud.sh internal-staging

.PHONY: prod_deploy
prod_deploy: package_cloud_deps rpm pkgcloud_stage pkgcloud_prod
.PHONY: pkgcloud_prod
pkgcloud_prod:
	bash deploy/push_packagecloud.sh internal
