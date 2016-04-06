# Read the version we are packaging from VERSION.txt
VERSION := $(shell cat VERSION.txt)

.PHONY: all
all: rpm

.PHONY: test
test: rpm_deps
	tests/confirm-rpm.sh

.PHONY: deps
deps: fpm_deps

.PHONY: with-native-tools
with-native-tools: rpm-with-native-tools

.PHONY: docker-deps
docker-deps:

.PHONY: rate_limit
rate_limit:
	curl -H "Authorization: token $$GITHUB_TOKEN" -XGET https://api.github.com/rate_limit

.PHONY: validate_circle
validate_circle:
	ruby -r yaml -e 'puts YAML.dump(STDIN.read)' < circle.yml

.PHONY: rpm_deps
rpm_deps:
	-which rpm &>/dev/null || (which apt-get &>/dev/null && sudo apt-get install rpm)
	-which rpm &>/dev/null || (which brew &>/dev/null && brew install rpm)

.PHONY: fpm_deps
fpm_deps: rpm_deps
	-which fpm &>/dev/null || gem install fpm

.PHONY: rpm
rpm:
	sh scripts/docker-outer.sh

.PHONY: rpm-with-native-tools
rpm-with-native-tools: fpm_deps
	sh scripts/dockerless.sh
