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

# Update self from GitHub
rm -f /tmp/update-tools.sh
curl -s https://raw.githubusercontent.com/Oqaasileriffik/lt-course/main/lecture01/scripts/update-debian.sh > /tmp/update-tools.sh
if [[ -s "/tmp/update-tools.sh" ]]; then
	A=$(cat /tmp/update-tools.sh | shasum)
	B=$(cat ~/bin/update-tools.sh | shasum)
	if [[ "$A" != "$B" ]]; then
		mv -v /tmp/update-tools.sh ~/bin/update-tools.sh
		chmod +x ~/bin/update-tools.sh
		echo "Newer update-tools.sh found - restarting..."
		exec ~/bin/update-tools.sh
		exit
	fi
fi

echo "Updating dependencies from apt-get"
apt-get -qy update
apt-get -qf install --no-install-recommends autoconf automake make wget libfile-homedir-perl libipc-run-perl libyaml-libyaml-perl libjson-perl libjson-xs-perl pkg-config python3 python3-json5 python3-levenshtein python3-yaml python3-click zip gawk bc ca-certificates subversion git xz-utils icu-devtools gh

echo ""
echo "Updating more dependencies"
apt-get -qf install --no-install-recommends cg3-dev divvun-gramcheck foma hfst libhfst-dev hfst-ospell hfst-ospell-dev
