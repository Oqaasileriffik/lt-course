#!/bin/bash
set -e

if [[ ! -x /usr/bin/sudo ]]; then
	echo "sudo not installed - you must first install the sudo package and ensure your user is allowed to sudo. Alternatively, read through this script and perform the steps manually."
	exit
fi

if [[ `whoami` == 'root' ]]; then
    echo "This script must not be run with sudo or as root"
    exit
fi

if [[ -e ~/langtech ]]; then
	echo "~/langtech already exists - if you really want to install from new, rename or delete the existing folder, then rerun this script."
	exit
fi

echo "Installing dependencies from apt-get - this may ask for your sudo password"
sudo apt-get -qy update
sudo apt-get -qf install --no-install-recommends autoconf automake make wget curl libfile-homedir-perl libipc-run-perl libyaml-libyaml-perl libjson-perl libjson-xs-perl pkg-config python3 python3-json5 zip gawk bc ca-certificates subversion git xz-utils icu-devtools gh

echo ""
echo "Enabling Apertium Nightly repository"
wget https://apertium.projectjj.com/apt/install-nightly.sh -O - | sudo bash

echo ""
echo "Installing more dependencies"
sudo apt-get -qf install --no-install-recommends cg3-dev divvun-gramcheck foma hfst libhfst-dev hfst-ospell hfst-ospell-dev

export GIELLA_CORE=~/langtech/giella-core
export PERL_UNICODE=SDA

set +e

GREP=`egrep '^export GIELLA_CORE=~/langtech/giella-core' ~/.profile ~/.zprofile 2>/dev/null`
if [[ -z "$GREP" ]]; then
	echo 'export GIELLA_CORE=~/langtech/giella-core' >> ~/.profile
	echo 'export GIELLA_CORE=~/langtech/giella-core' >> ~/.bashrc
	echo 'export GIELLA_CORE=~/langtech/giella-core' >> ~/.zprofile
fi

GREP=`egrep '^export PERL_UNICODE=SDA' ~/.profile ~/.zprofile 2>/dev/null`
if [[ -z "$GREP" ]]; then
	echo 'export PERL_UNICODE=SDA' >> ~/.profile
	echo 'export PERL_UNICODE=SDA' >> ~/.bashrc
	echo 'export PERL_UNICODE=SDA' >> ~/.zprofile
fi

set -e

git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global pull.ff only
git config --global fetch.prune true
git config --global diff.colorMoved zebra
git config --global push.default simple
git config --global core.eol lf
git config --global core.autocrlf false
git config --global status.short true
git config --global alias.up 'pull --all --rebase --autostash'
git config --global alias.ci 'commit'
git config --global blame.showEmail true
git config --global blame.date short

echo ""
echo "Checking out repositories"
mkdir -pv ~/langtech
pushd ~/langtech
git clone https://github.com/giellalt/giella-core giella-core
git clone https://github.com/giellalt/shared-mul shared-mul
git clone https://github.com/giellalt/regtest-kal regression
git clone https://github.com/giellalt/lang-kal kal
git clone https://github.com/TinoDidriksen/regtest regtest
git clone https://github.com/Oqaasileriffik/katersat katersat

echo ""
echo "Building giella-core"
pushd ~/langtech/giella-core
autoreconf -fi
./configure
make
popd

echo ""
echo "Building shared-mul"
pushd ~/langtech/shared-mul
autoreconf -fi
./configure
make
popd

echo ""
echo "Building kal"
pushd ~/langtech/kal
autoreconf -fi
./configure --without-forrest --with-hfst --without-xfst --enable-spellers --enable-hyperminimisation --enable-alignment --enable-minimised-spellers --enable-syntax --enable-analysers --enable-generators --enable-tokenisers --with-backend-format=foma --disable-hfst-desktop-spellers
make -j4
popd

mkdir -pv ~/bin
curl https://raw.githubusercontent.com/Oqaasileriffik/lt-course/main/lecture01/scripts/update-debian.sh > ~/bin/update-tools.sh
curl https://raw.githubusercontent.com/Oqaasileriffik/lt-course/main/lecture01/scripts/update-kal.sh > ~/bin/update-kal.sh
chmod +x ~/bin/*.sh

echo "MANUAL TODO:"
echo "Run these to set your name and email. Use the same name and email as you do for GitHub:"
echo '$ git config --global user.name "Your Name Goes Here"'
echo '$ git config --global user.email "your@email.com"'
