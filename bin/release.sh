#!/bin/bash

VERSION="$1"
BRANCH="RELEASE"

#sanity
if [[ -z "$VERSION" ]]; then
	echo "Usage: release.sh <version>"
	exit 0
fi

#prepare branch
git checkout master
git branch -D "$BRANCH"
git checkout -b "$BRANCH"

#update version
for file in "get.didregman.io" ".travis.yml"; do
	sed -i "s/@DRM_VERSION@/$VERSION/g" "$file"
	git add "$file"
done

git commit -m "Update version of $BRANCH to $VERSION"

#push branch
git push -f origin "$BRANCH:$BRANCH"

#push tag
git tag "$VERSION"
git push origin "$VERSION"

#back to master branch
git checkout master