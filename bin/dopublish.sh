#!/bin/bash

VERSION="$1"
BRANCH="RELEASE"

#sanity
if [[ -z "$VERSION" ]]; then
	echo "Usage: dopublish.sh <version>"
	exit 0
fi

#checkout release branch
git checkout -b "$BRANCH"

#prepare scripts
mkdir -p /build/scripts

# move files to build/scripts

cp src/main/bash/*.sh /build/scripts

# make drman-latest.zip 

unzip -xvf /tmp/drman-latest.zip /build/scripts
mkdir -p /build/distribution
cp /tmp/drman-latest.zip /tmp/drman-REL-${VERSION}.zip

# checkout dist branch

git checkout -b "dist"

# drman-latest.zip to dist branch
cp /tmp/drman-REL-${VERSION}.zip /dist
cp /tmp/drman-latest.zip /dist

git add /dist/drman-latest.zip
git add /dist/drman-REL-${VERSION}.zip
git commit - m "Published REL-${VERSION}"
git push origin dist

#back to dist branch
git checkout dist




