#!/bin/bash

if [[ `whoami` != 'root' ]]; then
    echo "This script must run with sudo or as root"
    exit
fi

# Update self from GitHub
rm -f /tmp/update-tools.sh
curl -s https://raw.githubusercontent.com/Oqaasileriffik/lt-course/main/lecture01/scripts/update-macos.sh > /tmp/update-tools.sh
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

echo "Updating tools"
cd /tmp/
curl https://apertium.projectjj.com/osx/install-nightly.sh | bash

echo "Updating MacPorts"
port selfupdate
port upgrade outdated

echo ""
echo "Removing unused ports"
port uninstall inactive

echo ""
echo "Updating required ports"
for PKG in subversion git pkgconfig autoconf automake gawk xz perl5 p5-file-homedir p5-ipc-run p5-app-cpanminus p5-yaml-libyaml p5-json p5-json-xs timeout python312 py312-regex py312-json5 py312-levenshtein gsed icu gh
do
	echo "... installing $PKG"
	yes | port install "$PKG" || echo "FAILED TO INSTALL $PKG"
done

port select --set python3 python312
