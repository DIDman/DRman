#!/bin/bash

VERSION="$1"
BRANCH="RELEASE"

#sanity
if [[ -z "$VERSION" ]]; then
	echo "Usage: dopublish.sh <version>"
	exit 0
fi

#checkout release branch
git checkout "$BRANCH"
#git checkout tags/<tag> -b <branch>
#echo git checkout tags/"$VERSION" -b "$BRANCH"
#prepare scripts
mkdir -p build/scripts


# move files to build/scripts

cp src/main/bash/*.sh build/scripts

# make drman-latest.zip 
mkdir -p tmp
zip -r tmp/drman-latest.zip build/scripts
mkdir -p build/distribution
cp tmp/drman-latest.zip tmp/drman-${VERSION}.zip

# Prepare dist branch
# checkout dist branch

git checkout "dist"

# move get.drman.io.tmpl to dist
cp dist/tmpl/get.drman.io.tmpl dist/get.drman.io

#update version on dist branch
for file in "dist/get.drman.io"; do
	#echo sed -i "s/@DRM_VERSION@/$VERSION/g" "$file"
	sed -i "s/@DRM_VERSION@/$VERSION/g" "$file"
	git add "$file"
done

#git commit -m "Update version of dist to $VERSION"


# drman-latest.zip to dist branch
cp tmp/drman-${VERSION}.zip dist/drman-${VERSION}.zip
cp tmp/drman-latest.zip dist/drman-latest.zip

git add dist/drman-latest.zip
git add dist/drman-$VERSION.zip
git commit -m "Published $VERSION"
git push origin dist

#back to dist branch
git checkout dist




