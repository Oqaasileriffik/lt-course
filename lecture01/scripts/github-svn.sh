#!/bin/bash
if [[ `whoami` == 'root' ]]; then
    echo "This script must not be run with sudo or as root"
    exit
fi

if [[ -d ~/langtech/giella-core ]]; then
	pushd ~/langtech/giella-core
	rm -rf .svn
	svn co -N https://github.com/giellalt/giella-core/trunk/ giella-core-tmp/
	mv -v giella-core-tmp/.svn ./
	svn up --set-depth infinity --force --accept tc
	svn revert -R .
	rm -rf giella-core-tmp
	popd
fi

if [[ -d ~/langtech/giella-shared ]]; then
	pushd ~/langtech/giella-shared
	rm -rf .svn
	svn co -N https://github.com/giellalt/giella-shared/trunk/ giella-shared-tmp/
	mv -v giella-shared-tmp/.svn ./
	svn up --set-depth infinity --force --accept tc
	svn revert -R .
	rm -rf giella-shared-tmp
	popd
fi

if [[ -d ~/langtech/regression ]]; then
	pushd ~/langtech/regression
	rm -rf .svn
	svn co -N https://github.com/giellalt/regtest-kal/trunk/ regtest-kal-tmp/
	mv -v regtest-kal-tmp/.svn ./
	svn up --set-depth infinity --force --accept tc
	svn revert -R .
	rm -rf regtest-kal-tmp
	popd
fi

if [[ -d ~/langtech/kal ]]; then
	pushd ~/langtech/kal
	rm -rf .svn
	svn co -N https://github.com/giellalt/lang-kal/trunk/ lang-kal-tmp/
	mv -v lang-kal-tmp/.svn ./
	svn up --set-depth infinity --force --accept tc
	svn revert -R .
	rm -rf lang-kal-tmp
	popd
fi
