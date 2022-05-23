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
sudo apt-get -qf install --no-install-recommends autoconf automake make wget libfile-homedir-perl libipc-run-perl libplack-perl libyaml-libyaml-perl libjson-perl libjson-xs-perl pkg-config python3 zip gawk bc ca-certificates subversion git xz-utils

echo ""
echo "Enabling Apertium Nightly repository"
wget https://apertium.projectjj.com/apt/install-nightly.sh -O - | sudo bash

echo ""
echo "Installing more dependencies"
sudo apt-get -qf install --no-install-recommends cg3-dev divvun-gramcheck foma hfst libhfst-dev hfst-ospell hfst-ospell-dev

export GIELLA_CORE=~/langtech/giella-core
export PERL_UNICODE=SDA

set +e

GREP=`egrep '^export GIELLA_CORE=~/langtech/giella-core' ~/.profile`
if [[ -z "$GREP" ]]; then
	echo 'export GIELLA_CORE=~/langtech/giella-core' >> ~/.profile
	echo 'export GIELLA_CORE=~/langtech/giella-core' >> ~/.bashrc
fi

GREP=`egrep '^export PERL_UNICODE=SDA' ~/.profile`
if [[ -z "$GREP" ]]; then
	echo 'export PERL_UNICODE=SDA' >> ~/.profile
	echo 'export PERL_UNICODE=SDA' >> ~/.bashrc
fi

set -e

echo ""
echo "Checking out repositories"
mkdir -pv ~/langtech
pushd ~/langtech
svn co https://github.com/giellalt/giella-core/trunk giella-core
svn co https://github.com/giellalt/shared-mul/trunk shared-mul
svn co https://github.com/giellalt/regtest-kal/trunk regression
svn co https://github.com/giellalt/lang-kal/trunk kal

pushd ~/langtech/regression
svn co https://github.com/TinoDidriksen/regtest/trunk/ regtest/
popd

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
