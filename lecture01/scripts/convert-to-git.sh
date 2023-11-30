#!/bin/bash
set -e

if [[ `whoami` == 'root' ]]; then
	echo "This script must not be run with sudo or as root"
	exit
fi

echo "IMPORTANT: Commit or undo all changes to versioned files before running this script!"
echo ""

echo "Installing GitHub CLI (gh) - this may ask for sudo password"
if [[ `uname -o` == 'Darwin' ]]; then
	sudo port selfupdate
	sudo port install gh
else
	type -p curl >/dev/null || (sudo apt-get update && sudo apt-get -qfy install curl)
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt-get update \
	&& sudo apt-get -qfy install gh
fi
echo ""

echo "Authenticating with GitHub"
gh auth login --hostname github.com --git-protocol https --web
echo ""

echo "Configuring git to use GitHub CLI for authentication"
gh auth setup-git
echo ""

git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global pull.ff only
git config --global fetch.prune true
git config --global diff.colorMoved zebra
git config --global push.default simple

cd ~/langtech
rm -rf tmp-gh

if [[ -d regression/.svn ]]; then
	echo "Converting regression"
	svn up regression
	gh repo clone https://github.com/giellalt/regtest-kal tmp-gh
	rm -rf regression/.svn
	mv tmp-gh/.git regression/
	rm -rf tmp-gh
	echo ""
fi

if [[ -d nutserut/.svn ]]; then
	echo "Converting nutserut"
	svn up nutserut
	gh repo clone https://github.com/Oqaasileriffik/nutserut tmp-gh
	rm -rf nutserut/.svn
	mv tmp-gh/.git nutserut/
	rm -rf tmp-gh
	echo ""
fi

if [[ -d corpora/.svn ]]; then
	echo "Converting corpora"
	svn up corpora
	gh repo clone https://github.com/giellalt/corpus-kal tmp-gh
	rm -rf corpora/.svn
	mv tmp-gh/.git corpora/
	rm -rf tmp-gh
	echo ""
fi

if [[ -d giella-core/.svn ]]; then
	echo "Converting giella-core"
	svn up giella-core
	gh repo clone https://github.com/giellalt/giella-core tmp-gh
	rm -rf giella-core/.svn
	mv tmp-gh/.git giella-core/
	rm -rf tmp-gh
	echo ""
fi

if [[ -d shared-mul/.svn ]]; then
	echo "Converting shared-mul"
	svn up shared-mul
	gh repo clone https://github.com/giellalt/shared-mul tmp-gh
	rm -rf shared-mul/.svn
	mv tmp-gh/.git shared-mul/
	rm -rf tmp-gh
	echo ""
fi

if [[ -d kal/.svn ]]; then
	echo "Converting kal"
	svn up kal
	gh repo clone https://github.com/giellalt/lang-kal tmp-gh
	rm -rf kal/.svn
	mv tmp-gh/.git kal/
	rm -rf tmp-gh
	echo ""
fi

echo "All done - for git commands, see https://docs.google.com/document/d/1EJwhMETEMqAT4jQUDKoTg1cS35RBpMug9oKtd9E_za8"
