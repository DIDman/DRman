#!/bin/bash

version="$1"
branch="RELEASE"

#sanity
if [[ -z "$version" ]]; then
	echo "Usage: release.sh <version>"
	exit 0
fi


#prepare master branch
git checkout master
git branch -D "$branch"
git checkout -b "$branch"


# update version on release branch
for file in ".travis.yml"; do
	echo sed -i "s/@DRMAN_VERSION@/$version/g" "$file"
	echo git add "$file"
done

git commit -m "Update version of $branch to $version"

#push release branch
git push -f origin "$branch:$branch"

#push tag
git tag "$version"
git push origin "$version"

#back to master branch
git checkout master

