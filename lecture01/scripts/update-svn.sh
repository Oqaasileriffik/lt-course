#!/bin/bash

if [[ `whoami` == 'root' ]]; then
    echo "This script must not be run with sudo or as root"
    exit
fi

if [[ -d ~/langtech/regression ]]; then
	pushd ~/langtech/regression
	svn cleanup
	svn upgrade
	svn up
	svn cleanup
	popd
fi

if [[ -d ~/langtech/regression/regtest ]]; then
	pushd ~/langtech/regression/regtest
	svn cleanup
	svn upgrade
	svn up
	svn cleanup
	popd
fi

if [[ -d ~/langtech/nutserut ]]; then
	pushd ~/langtech/nutserut
	svn cleanup
	svn upgrade
	svn up
	svn cleanup
	popd
fi

if [[ -d ~/langtech/giella-core ]]; then
	export GIELLA_CORE=~/langtech/giella-core
	pushd ~/langtech/giella-core
	svn cleanup
	svn upgrade
	svn revert -R .
	svn stat --no-ignore | grep '^[?I]' | xargs -n1 rm -rfv --
	svn up
	svn cleanup
	autoreconf -fvi
	./configure
	make
	popd
fi

if [[ -d ~/langtech/giella-shared ]]; then
	export GIELLA_SHARED=~/langtech/giella-shared
	pushd ~/langtech/giella-shared
	svn cleanup
	svn upgrade
	svn revert -R .
	svn stat --no-ignore | grep '^[?I]' | xargs -n1 rm -rfv --
	svn up
	svn cleanup
	autoreconf -fvi
	./configure
	make
	popd
fi

if [[ -d ~/langtech/kal ]]; then
	pushd ~/langtech/kal
	svn cleanup
	svn upgrade
	svn up
	svn cleanup
	autoreconf -fvi
	./configure --without-forrest --with-hfst --without-xfst --enable-spellers --enable-hyperminimisation --enable-alignment --enable-minimised-spellers --enable-syntax --enable-analysers --enable-generators --enable-tokenisers --with-backend-format=foma --disable-hfst-desktop-spellers --disable-hfst-dekstop-spellers
	make -j4
	popd
fi
