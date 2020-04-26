#!/bin/bash

VERSION="$1"
BRANCH="RELEASE"

#sanity
if [[ -z "$VERSION" ]]; then
	echo "Usage: release.sh <version>"
	exit 0
fi


#prepare master branch
git checkout master
git branch -D "$BRANCH"
git checkout -b "$BRANCH"


# update version on release branch
for file in ".travis.yml"; do
	echo sed -i "s/@DRM_VERSION@/$VERSION/g" "$file"
	echo git add "$file"
done

git commit -m "Update version of $BRANCH to $VERSION"

#push release branch
git push -f origin "$BRANCH:$BRANCH"

#push tag
git tag "$VERSION"
git push origin "$VERSION"

#back to master branch
git checkout master

