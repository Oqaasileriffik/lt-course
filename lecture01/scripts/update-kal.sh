#!/bin/bash

if [[ `whoami` == 'root' ]]; then
    echo "This script must not be run with sudo or as root"
    exit
fi

# Update self from GitHub
rm -f /tmp/update-kal.sh
curl -s https://raw.githubusercontent.com/Oqaasileriffik/lt-course/main/lecture01/scripts/update-kal.sh > /tmp/update-kal.sh
if [[ -s "/tmp/update-kal.sh" ]]; then
	A=$(cat /tmp/update-kal.sh | shasum)
	B=$(cat ~/bin/update-kal.sh | shasum)
	if [[ "$A" != "$B" ]]; then
		mv -v /tmp/update-kal.sh ~/bin/update-kal.sh
		chmod +x ~/bin/update-kal.sh
		echo "Newer update-kal.sh found - restarting..."
		exec ~/bin/update-kal.sh
		exit
	fi
fi

export LD_PRELOAD=libtcmalloc_minimal.so

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
		git pull --all --rebase --autostash
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

# Clean up old stuff
if [[ -d ~/langtech/regression/regtest ]]; then
	rm -rfv ~/langtech/regression/regtest
fi

if [[ -d ~/langtech/regression ]]; then
	pull_git_svn ~/langtech/regression
fi

if [[ ! -d ~/langtech/regtest ]]; then
	git clone https://github.com/TinoDidriksen/regtest ~/langtech/regtest
fi
if [[ -d ~/langtech/regtest ]]; then
	pull_git_svn ~/langtech/regtest
fi

if [[ ! -d ~/langtech/katersat ]]; then
	git clone https://github.com/Oqaasileriffik/katersat ~/langtech/katersat
fi
if [[ -d ~/langtech/katersat ]]; then
	pushd ~/langtech/katersat
	pull_git_svn ~/langtech/katersat
	./update.py
	popd
fi

if [[ ! -d ~/langtech/gloss ]]; then
	git clone https://github.com/Oqaasileriffik/gloss ~/langtech/gloss
fi
if [[ -d ~/langtech/gloss ]]; then
	pull_git_svn ~/langtech/gloss
fi

if [[ -d ~/langtech/nutserut ]]; then
	pull_git_svn ~/langtech/nutserut
	rm -rf ~/langtech/nutserut/regtest
	ln -s ../regtest ~/langtech/nutserut/regtest
fi

if [[ -d ~/langtech/corpora ]]; then
	pull_git_svn ~/langtech/corpora
fi

if [[ -d ~/langtech/giella-core ]]; then
	export GIELLA_CORE=~/langtech/giella-core
	pull_git_svn ~/langtech/giella-core
fi

if [[ -d ~/langtech/shared-mul ]]; then
	pull_git_svn ~/langtech/shared-mul
fi

if [[ -d ~/langtech/kal ]]; then
	pushd ~/langtech/kal
	if [[ -d .git ]]; then
		git checkout -- docs
	else
		svn revert -R docs
	fi
	pull_git_svn ~/langtech/kal
	autoreconf -fvi
	./configure --without-forrest --with-hfst --without-xfst --enable-spellers --enable-hyperminimisation --enable-alignment --enable-minimised-spellers --enable-syntax --enable-analysers --enable-generators --enable-tokenisers --with-backend-format=foma --disable-hfst-desktop-spellers
	make -j8
	popd
fi
