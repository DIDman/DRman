#!/bin/bash
# github-create-gvcr

# usage details
usage() {
  cat << EOF
[`basename $0`]
USAGE: `basename $0` [-h]
       `basename $0` [-l]
       `basename $0` [-v] [-o orgname] [-r reponame]

OPTIONS:
  -h  usage
  -r  repository name (default is the current directory base name)
  -o  github organization name
  -v  verbose (debugging)
  -l  list remote repositories (diagnostic only)

See http://developer.github.com/v3/ for GitHub API v3. Note that curl is being
used to perform the GET and POST requests provided in the API, as demonstrated
in some of the examples on the main page.
EOF
}

# default options
reponame=`basename $(pwd)`
verbose=false
list_only=false

# parse options using getopts
while getopts ":hr:m:d:o:u:f:vl" OPTION # while getopts ":hr:c:m:vl" OPTION
do
  case $OPTION in
    h)  usage
        exit 0
        ;;
    r)  reponame=$OPTARG
        ;;
    o)  orgname=$OPTARG
        ;;
    v)  verbose=true
        ;;
    l)  list_only=true
        ;;
    :)  echo "`basename $0`: $OPTARG requires an argument to be provided"
        echo "See '`basename $0` -h' for usage details"
        exit 1
        ;;
    ?)  echo "`basename $0`: $OPTARG invalid"
        echo "See '`basename $0` -h' for usage details"
        exit 1
        ;;
  esac
done

# start working
echo "[`basename $0`]"

# validate github credentials for https security 
if [ "$orgname" = "" ]; then
  echo "Enter a organization name: use -o <organization name>"
  exit 3
fi

# List all the organization repos
if $list_only; then
  if $verbose; then echo "Listing remote repositories ..."; fi
  ./api-github-vcr.sh list-organization-repositories $orgname 
  exit $?
fi

# sanity check before messing with remote server
echo "Parameters provided or default parameters assumed"
echo "  organization name = $orgname"
echo "  repository name = $reponame"
echo "  platform = Github"
read -p "Proceed [y/n]: " answer
if [ $answer != "y" ]; then
  echo "`basename $0`: aborted"
  exit 0
fi

export verbose
# create an organization if it doesn't exists
./api-github-vcr.sh find-organization $orgname
  if [ $? -ne 0 ]; then
      ./api-github-vcr.sh create-organization $orgname
      if [ $? -ne 0 ]; then exit $?; fi
  fi
  
# check if user is a member of the organization
./api-github-vcr.sh check-organization-membership $orgname
if [ $? -ne 0 ]; then exit $?; fi

# TODO: check for existing repository

# create a gitub repository
./api-github-vcr.sh create-repository $orgname $reponame
if [ $? -ne 0 ]; then exit $?; fi

# prepare the template of repository
# TODO: Get a path from the user
username=`git config --global github.user`
mkdir ./$reponame && cd $reponame
touch .gitignore
touch README.md
mkdir "./admin" && cd "admin"
mkdir $username && cd $username
touch DID.txt
cd ../..
# TODO: integrate generate did script
# TODO: add restrictions
git init 
git add .gitignore README.md admin
git commit -m "genesis transaction"
git remote add gvcr "https://github.com/$orgname/$reponame.git"
git push -u gvcr master 

if $verbose; then echo "`basename $0`: finished"; fi