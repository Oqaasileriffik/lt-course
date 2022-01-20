#!/bin/bash

if [[ `whoami` != 'root' ]]; then
    echo "This script must run with or as root"
    exit
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
for PKG in subversion git pkgconfig autoconf automake gawk xz perl5 p5-file-homedir p5-ipc-run p5-app-cpanminus p5-plack p5-yaml-libyaml p5-json p5-json-xs timeout python310
do
	echo "... installing $PKG"
	yes | port install "$PKG" || echo "FAILED TO INSTALL $PKG"
done

sudo port select --set python3 python310
