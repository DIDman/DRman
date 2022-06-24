#!/bin/bash
# github-create-gvcr

# usage details
usage() {
  cat << EOF
[`basename $0`]
USAGE: `basename $0` [-h]
       `basename $0` [-l]
       `basename $0` [-v] [-o ORGNAME] [-r REPONAME]

OPTIONS:
  -h  usage
  -r  repository name (default is the current directory base name)
  -o  github organization name
  -v  VERBOSE (debugging)
  -l  list remote repositories (diagnostic only)

See http://developer.github.com/v3/ for GitHub API v3. Note that curl is being
used to perform the GET and POST requests provided in the API, as demonstrated
in some of the examples on the main page.
EOF
}

# default options
REPONAME=`basename $(pwd)`
VERBOSE=false
list_only=false

# parse options using getopts
while getopts ":hr:m:d:o:u:f:vl" OPTION # while getopts ":hr:c:m:vl" OPTION
do
  case $OPTION in
    h)  usage
        exit 0
        ;;
    r)  REPONAME=$OPTARG
        ;;
    o)  ORGNAME=$OPTARG
        ;;
    v)  VERBOSE=true
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
if [ "$ORGNAME" = "" ]; then
  echo "Enter a organization name: use -o <organization name>"
  exit 3
fi

# List all the organization repos
if $list_only; then
  if $VERBOSE; then echo "Listing remote repositories ..."; fi
  ./api-github-vcr.sh list-organization-repositories $ORGNAME 
  exit $?
fi

# sanity check before messing with remote server
echo "Parameters provided or default parameters assumed"
echo "  organization name = $ORGNAME"
echo "  repository name = $REPONAME"
echo "  regitsry provider = Github"
read -p "Proceed [y/n]: " answer
if [ $answer != "y" ]; then
  echo "`basename $0`: aborted"
  exit 0
fi

export VERBOSE
export ORGNAME
export REPONAME

# create an organization if it doesn't exists
./api-github-vcr.sh find-organization
  if [ $? -ne 0 ]; then
      ./api-github-vcr.sh create-organization
      if [ $? -ne 0 ]; then exit $?; fi
  fi
  
# check if user is a member of the organization
./api-github-vcr.sh check-organization-membership
if [ $? -ne 0 ]; then exit $?; fi

# TODO: check for existing repository

# create a gitub repository
./api-github-vcr.sh create-repository
if [ $? -ne 0 ]; then exit $?; fi

# Prepare the template of repository
username=`git config --global github.user`
mkdir ./$REPONAME && cd $REPONAME
touch .gitignore
touch README.md
mkdir "./admin" && cd "admin"
mkdir $username && cd $username
touch DID.txt
cd ../..
# TODO: integrate generate did script
git init 
git add .gitignore README.md admin
git commit -sm "genesis transaction"
git remote add gvcr "https://github.com/$ORGNAME/$REPONAME.git"
git push -u gvcr master

# return to root folder
cd ..
# add branch protection
./api-github-vcr.sh add-branch-protection
if [ $? -ne 0 ]; then exit $?; fi

# add signature protection
./api-github-vcr.sh add-signature-protection
if [ $? -ne 0 ]; then exit $?; fi

if $VERBOSE; then echo "`basename $0`: finished"; fi