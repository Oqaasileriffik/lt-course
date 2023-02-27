#!/bin/bash
set -e

if [[ ! -x /usr/bin/sudo ]]; then
	echo "sudo not installed - you must first install the sudo package and ensure your user is allowed to sudo. Alternatively, read through this script and perform the steps manually."
	exit
fi

if [[ `whoami` != 'root' ]]; then
    echo "This script must be run with sudo or as root"
    exit
fi

echo "Updating dependencies from apt-get"
apt-get -qy update
apt-get -qf install --no-install-recommends autoconf automake make wget libfile-homedir-perl libipc-run-perl libplack-perl libyaml-libyaml-perl libjson-perl libjson-xs-perl pkg-config python3 zip gawk bc ca-certificates subversion git xz-utils icu-devtools gh

echo ""
echo "Updating more dependencies"
apt-get -qf install --no-install-recommends cg3-dev divvun-gramcheck foma hfst libhfst-dev hfst-ospell hfst-ospell-dev
