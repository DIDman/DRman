#!/bin/bash

version="$1"
branch="RELEASE"
drman_namespace="${DRMAN_NAMESPACE:-DIDman}"
drman_candidate_branch="${DRMAN_CANDIDATE_BRANCH:-candidates}"
drman_candidate_repo_version="${DRMAN_CANDIDATE_REPO_VERSION:-1}"
drman_candidates_api="https://raw.githubusercontent.com/${drman_namespace}/DRman/${drman_candidate_branch}/candidates/${drman_candidate_repo_version}"
#sanity
if [[ -z "$version" ]]; then
	echo "Usage: dopublish.sh <version>"
	exit 0
fi

#checkout release branch
git checkout "$branch"

#prepare scripts
mkdir -p build/scripts


# move files to build/scripts

cp src/main/bash/*.sh build/scripts


#update version,namespace and candidate branch in scripts
for file in "build/scripts/drman-init.sh" ; do
	#echo sed -i "s/@DRMAN_VERSION@/$VERSION/g" "$file"
	sed -i "s/@DRMAN_VERSION@/$version/g" "$file"
	sed -i "s/@DRMAN_NAMESPACE@/$drman_namespace/g" "$file"
	sed -i "s/@DRMAN_CANDIDATE_BRANCH@/$drman_candidate_branch/g" "$file"
	sed -i "s/@DRMAN_CANDIDATE_REPO_VERSION@/$drman_candidate_repo_version/g" "$file"
    sed -i "s/@DRMAN_CANDIDATES_API@/$drman_candidates_api/g" "$file"

	git add "$file"
done

# make drman-latest.zip 
mkdir -p tmp
zip -rj tmp/drman-latest.zip build/scripts/*.sh
mkdir -p build/distribution
cp tmp/drman-latest.zip tmp/drman-${version}.zip

# Prepare dist branch
# checkout dist branch

git checkout "dist"

# move get.drman.io.tmpl to dist
cp dist/tmpl/get.drman.io.tmpl dist/get.drman.io

#update version on dist branch
for file in "dist/get.drman.io"; do
	#echo sed -i "s/@DRMAN_VERSION@/$VERSION/g" "$file"
	sed -i "s/@DRMAN_VERSION@/$version/g" "$file"
	git add "$file"
done

#git commit -m "Update version of dist to $VERSION"


# drman-latest.zip to dist branch
cp tmp/drman-${version}.zip dist/drman-${version}.zip
cp tmp/drman-latest.zip dist/drman-latest.zip

git add dist/drman-latest.zip
git add dist/drman-$version.zip
git commit -m "Published $version"
git push origin dist

#back to dist branch
git checkout dist




