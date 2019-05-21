#!/bin/bash

# Ensure we have a talk repo name.
NAME="$1"
PUBLIC="$2"
if [ "$NAME" = "" ]; then
	echo >&2 "Usage: $0 talk-repo-name [public]"
	exit 2
fi

set -o errexit
set -o nounset


# Check for GitHub/GitLab client first.
if [ "$PUBLIC" = "public" ]; then
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
else
	if ! which gitlab >/dev/null; then
		echo 'Installing python-gitlab...'
		pip3 install python-gitlab
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
if [ "$PUBLIC" = "public" ]; then
	hub create qntln/$NAME
	git checkout -b gh-pages
	echo "---> Talk will be available at https://qntln.github.io/$NAME/"
else
	# ID 67 == meta/talks
	gitlab project create --namespace-id 67 --name "$NAME"
	git remote add origin "ssh://git@gitlab.int.quantlane.com:2132/meta/$NAME.git"
	echo "---> Talk will be available at https://gitlab.int.quantlane.com/meta/$NAME"
fi
cp -r $HERE/{index.html,css,img,js,lib,plugin} .
git add .
git commit -m 'Empty template'
git push origin --set-upstream
