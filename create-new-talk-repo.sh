#!/bin/bash

# Ensure we have a talk repo name.
NAME="$1"
if [ "$NAME" = "" ]; then
	echo >&2 "Usage: $0 talk-repo-name"
	exit 2
fi

set -o errexit
set -o nounset


# Check for `hub` first.
if ! which hub >/dev/null; then
	# If this is a Mac we know how to install it automatically.
	if which brew >/dev/null; then
		echo 'Installing `hub`...'
		brew install hub
	else
		echo >&2 'Install the `hub` utility first. See https://hub.github.com.'
		exit 1
	fi
fi

realpath() {
	[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

HERE=$(dirname $(realpath $0))
ROOT=$HERE/..

echo "Creating $NAME in $ROOT"
cd $ROOT
mkdir $NAME
cd $NAME
git init
hub create qntln/$NAME
cp -r $HERE/{index.html,css,img,js,lib,plugin} .
git checkout -b gh-pages
git add .
git commit -m 'Empty template'
git push origin --set-upstream

echo "Talk will be available at https://qntln.github.io/$NAME/"
