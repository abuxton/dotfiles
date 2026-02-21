#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

if [ -z "$CI" ]; then git pull origin main; fi;

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "assets/" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		--exclude "brew.sh" \
		--exclude "*.md" \
		-avh --no-perms . ~;
	#source ~/.bash_profile;
	if [ -z "$CI" ]; then source ~/.zshrc; fi;
}
function makeItHappen () {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
function nodeKnows(){
if ! [ -x "$(command -v add-gitignore)" ]; then
	cd $HOME && npm i -g add-gitignore  #https://github.com/TejasQ/add-gitignore
fi
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		makeItHappen;
		doIt;
        nodeKnows;
	fi;
fi;
unset doIt;
unset makeItHappen;
unset nodeKnows;
