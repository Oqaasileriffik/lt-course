#!/bin/bash

if [[ `whoami` == 'root' ]]; then
    echo "This script must not be run with sudo or as root"
    exit
fi

export LD_PRELOAD=libtcmalloc_minimal.so

function pull_git_svn {
	pushd "$1"
	if [[ -d .git ]]; then
		git pull --rebase --autostash --all
	else
		svn cleanup
		svn upgrade
		svn up
		svn cleanup
	fi
	popd
}

function pull_git_svn_revert {
	pushd "$1"
	if [[ -d .git ]]; then
		git fetch --all -f
		git remote update -p
		git reflog expire --expire=now --all
		git reset --hard HEAD
	else
		svn cleanup
		svn upgrade
		svn revert -R .
		svn stat --no-ignore | grep '^[?I]' | xargs -n1 rm -rfv --
		svn up
		svn cleanup
	fi
	autoreconf -fvi
	./configure
	make
	popd
}

if [[ -d ~/langtech/regression ]]; then
	pull_git_svn ~/langtech/regression
fi

if [[ -d ~/langtech/regression/regtest ]]; then
	pull_git_svn ~/langtech/regression/regtest
fi

if [[ -d ~/langtech/nutserut ]]; then
	pull_git_svn ~/langtech/nutserut
fi

if [[ -d ~/langtech/corpora ]]; then
	pull_git_svn ~/langtech/corpora
fi

if [[ -d ~/langtech/giella-core ]]; then
	export GIELLA_CORE=~/langtech/giella-core
	pull_git_svn_revert ~/langtech/giella-core
fi

if [[ -d ~/langtech/giella-shared ]]; then
	export GIELLA_SHARED=~/langtech/giella-shared
	pull_git_svn_revert ~/langtech/giella-shared
fi

if [[ -d ~/langtech/shared-mul ]]; then
	pull_git_svn_revert ~/langtech/shared-mul
fi

if [[ -d ~/langtech/kal ]]; then
	pushd ~/langtech/kal
	if [[ -d .git ]]; then
		git restore docs
	else
		svn revert -R docs
	fi
	pull_git_svn ~/langtech/kal
	autoreconf -fvi
	./configure --without-forrest --with-hfst --without-xfst --enable-spellers --enable-hyperminimisation --enable-alignment --enable-minimised-spellers --enable-syntax --enable-analysers --enable-generators --enable-tokenisers --with-backend-format=foma --disable-hfst-desktop-spellers
	make -j4
	popd
fi
