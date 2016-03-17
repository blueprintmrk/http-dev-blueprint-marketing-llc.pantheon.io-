# RPM for wp-cli

This repository builds an RPM for wp-cli.

## Relevant wp-cli RPM names

- wp-cli: Legacy RPM containing wp-cli and wp_launch_check
- wp-cli-0: RPM containing only wp-cli (version 0.x)
- wp-launch-check: RPM containing only wp_launch_check

The RPM filename built by this repository is:
```
wp-cli-0-release-0.22.0-ts201603151156.git4602714.x86_64.rpm
{ name }-{ type}-{vers}-{ iteration #}.{ commit }.{arch}.rpm
```
The iteration number is the Circle build number for officiel builds, and a timestamp ("tsYYYMMDDHHmm") for locally-produced builds. The build script will refuse to make an RPM when there are uncommitted changes to the working tree, since the commit hash is included in the RPM name.

## Install Location

This rpm installs:

/opt/wp0/wp-cli.phar

## Releasing to Package Cloud

Any time a commit is merged on a tracked branch, then a wp-cli RPM is built and pushed up to Package Cloud.

Branch       | Target
------------ | ---------------
master       | pantheon/internal/fedora/#
stage        | pantheon/internal-staging/fedora/#

In the table above, # is the fedora build number (19, 20, 22).

To release a new version of wp-cli, simply update the VERSION.txt file and commit. Run `make` to build locally, or push to one of the branches above to have an official RPM built and pushed to Package Cloud.

## Provisioning wp-cli on Pantheon

Pantheon will automatically install any new RPM that is deployed to Package Cloud. This is controlled by [pantheon-cookbooks/wp-cli](https://github.com/pantheon-cookbooks/wp-cli/blob/master/recipes/default.rb).

## wp-cli RPM versioning strategy

If there is ever a wp-cli version 1.x, then we will maintain both wp-cli-0 and wp-cli-1 RPMs, so that legacy WordPress sites can continue to run 0.x until ready to upgrade.

If wp-cli ever releases a 0.x build that accidentally breaks backwards compatibility with old Pantheon sites, then we simply will not install that version until the bug is fixed in a future 0.x release.  If wp-cli ever makes a permanent change to the 0.x line that breaks backwards compatibility with old Pantheon sites without bumping its version up to 1.x, then we will simply need to make another RPM named something other than '-0' or '-1'.


