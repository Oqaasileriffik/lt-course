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

if [[ `uname -s` == 'Darwin' ]]; then
	export "PYTHONPATH=$PYTHONPATH:/usr/local/lib/python3.12/site-packages"
else
	export LD_PRELOAD=libtcmalloc_minimal.so
fi
NEED_RECONF=""

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

function git_pull {
	pushd "$1"
	git pull --rebase --autostash --all
	popd
}

function pull_acm {
	pushd "$1"
	CHANGED=$(git fetch --dry-run 2>&1)
	NEED_RECONF+=$CHANGED
	git fetch --all -f
	git remote update -p
	git reflog expire --expire=now --all
	git reset --hard HEAD
	git pull --all --rebase --autostash
	if [[ ! -z "$CHANGED" || ! -s "configure" || ! -s "Makefile" ]]; then
		autoreconf -fvi
		./configure
		make
	fi
	popd
}

# Clean up old stuff
if [[ -d ~/langtech/regression/regtest ]]; then
	rm -rfv ~/langtech/regression/regtest
fi

if [[ -d ~/langtech/regression ]]; then
	git_pull ~/langtech/regression
fi

if [[ ! -d ~/langtech/regtest ]]; then
	git clone https://github.com/TinoDidriksen/regtest ~/langtech/regtest
fi
if [[ -d ~/langtech/regtest ]]; then
	git_pull ~/langtech/regtest
fi

if [[ ! -d ~/langtech/katersat ]]; then
	git clone https://github.com/Oqaasileriffik/katersat ~/langtech/katersat
fi
if [[ -d ~/langtech/katersat ]]; then
	pushd ~/langtech/katersat
	git pull --rebase --autostash --all
	./update.py
	popd
fi

if [[ ! -d ~/langtech/gloss ]]; then
	git clone https://github.com/Oqaasileriffik/gloss ~/langtech/gloss
fi
if [[ -d ~/langtech/gloss ]]; then
	git_pull ~/langtech/gloss
fi

if [[ -d ~/langtech/nutserut ]]; then
	git_pull ~/langtech/nutserut
	rm -rf ~/langtech/nutserut/regtest
	ln -s ../regtest ~/langtech/nutserut/regtest
fi

if [[ -d ~/langtech/corpora ]]; then
	git_pull ~/langtech/corpora
fi

if [[ -d ~/langtech/giella-core ]]; then
	export GIELLA_CORE=~/langtech/giella-core
	pull_acm ~/langtech/giella-core
fi

if [[ -d ~/langtech/shared-mul ]]; then
	pull_acm ~/langtech/shared-mul
fi

if [[ -d ~/langtech/kal ]]; then
	pushd ~/langtech/kal
	git checkout -- docs

	NEED_RECONF+=$(git fetch --dry-run 2>&1)
	git pull --rebase --autostash --all

	echo "'$@'" > config.kal.new
	if [[ ! -s "config.kal" ]]; then
		echo "1" > config.kal
	fi
	A=$(cat config.kal | shasum)
	B=$(cat config.kal.new | shasum)
	if [[ "$A" != "$B" ]]; then
		NEED_RECONF+='1'
	fi

	if [[ ! -z "$NEED_RECONF" || ! -s "configure" || ! -s "Makefile" ]]; then
		NEED_RECONF+='1'
		autoreconf -fvi
		./configure --without-forrest --with-hfst --without-xfst --enable-hyperminimisation --enable-alignment --enable-minimised-spellers --enable-syntax --enable-analysers --enable-generators --enable-tokenisers --with-backend-format=foma --disable-hfst-desktop-spellers "$@"
	fi

	NEED_RECONF+=$(git status -uno 2>&1)
	if [[ ! -z "$NEED_RECONF" ]]; then
		pushd tools/grammarcheckers
			make dev
		popd
		make -j
		mv config.kal.new config.kal
	fi
	popd
fi
