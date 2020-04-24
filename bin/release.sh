#!/bin/bash

VERSION="$1"
BRANCH="RELEASE"

#sanity
if [[ -z "$VERSION" ]]; then
	echo "Usage: release.sh <version>"
	exit 0
fi

#prepare dist branch
git checkout dist

# move get.drman.io.tmpl to dist
cp dist/tmpl/get.drman.io.tmpl dist/get.drman.io

#update version on dist branch
for file in "dist/get.didregman.io" "mkdocs.yml"; do
	sed -i "s/@DRM_VERSION@/$VERSION/g" "$file"
	git add "$file"
done

git commit -m "Update version of dist to $VERSION"

#push dist branch
git push -f origin dist

#prepare master branch
git checkout master
git branch -D "$BRANCH"
git checkout -b "$BRANCH"

# move get.drman.io.tmpl to dist
cp dist/tmpl/get.drman.io.tmpl dist/get.drman.io

#update version on release branch
for file in ".travis.yml"; do
	sed -i "s/@DRM_VERSION@/$VERSION/g" "$file"
	git add "$file"
done

git commit -m "Update version of $BRANCH to $VERSION"

#push release branch
git push -f origin "$BRANCH:$BRANCH"

#push tag
git tag "$VERSION"
git push origin "$VERSION"

#back to master branch
git checkout master

