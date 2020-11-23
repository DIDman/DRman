#!/bin/bash
# github-create-repo

# usage details
usage() {
  cat << EOF
[`basename $0`]
USAGE: `basename $0` [-h]
       `basename $0` [-l]
       `basename $0` [-v] [-r reponame] [-m message]
       `basename $0` [-v] [-u username] [-f token] [-r reponame] [-m message]

OPTIONS:
  -h  usage
  -r  repository name (default is the current directory base name)
  -m  commit message (default is automated)
  -d  enterprise domain api / host api (default is api.github.com)
  -u  github username (default is global config)
  -f  github personal access token (file) (default is global config)
  -v  verbose (debugging)
  -l  list remote repositories (diagnostic only)

See http://developer.github.com/v3/ for GitHub API v3. Note that curl is being
used to perform the GET and POST requests provided in the API, as demonstrated
in some of the examples on the main page.
EOF
}

# default options
reponame=`basename $(pwd)`
message="github-create-repo commit (automated)"
hostname="github.com"
hostapi="api.github.com"
username=`git config --global github.user`
apitoken=`git config --global github.token`
verbose=false
list_only=false

# parse options using getopts
while getopts ":hr:m:d:u:f:vl" OPTION # while getopts ":hr:c:m:vl" OPTION
do
  case $OPTION in
    h)  usage
        exit 0
        ;;
    r)  reponame=$OPTARG
        ;;
    m)  message=$OPTARG
        ;;
    d)  hostname=$OPTARG
        hostapi=$OPTARG/api/v3
        ;;
    u)  username=$OPTARG
        ;;
    f)  apitoken=`git config --file $OPTARG github.token`
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
if [ "$username" = "" ]; then
  echo "Could not find username: run 'git config --global github.user <username>'"
  invalid_credentials=1
fi
if [ "$apitoken" = "" ]; then
  echo "Could not find personal access token for https security: run 'git config --global github.token <token>'"
  invalid_credentials=1
fi
if [ "$invalid_credentials" = "1" ]; then
  echo "`basename $0`: invalid github credentials (see report above)"
  exit 3
fi

# simply list all repos
if $list_only; then
  if $verbose; then echo "Listing remote repositories ..."; fi
  curl -s -u "$username:$apitoken" https://$hostapi/user/repos | grep "\"full_name\":" | cut -d \" -f 4 2>&1
    if [ $? -ne 0 ]; then echo "`basename $0`: curl could not perform GET"; exit 5; fi
  exit 0
fi

# sanity check before messing with remote server
echo "Parameters provided or default parameters assumed"
echo "  repository name = $reponame"
echo "  commit message = $message"
echo "  domain name (api) = $hostname ($hostapi)"
echo "  github username = $username"
echo "  github personal access token = $apitoken"
echo -n "Proceed [y/n]:"
read answer
if [ $answer != "y" ]; then
  echo "`basename $0`: aborted"
  exit 0
fi

# check if directory is already tracked
if $verbose; then echo "Creating local / github repository ..."; fi
if [ -d .git ]; then
  git remote show origin
  echo "`basename $0`: directory already tracked"
  exit 7
fi

# check for .gitignore and README.md
if [ ! -f .gitignore ]; then
  if $verbose; then echo "Custom .gitnore not found: attempting to copy standard .gitignore from ~/.github-repo-defaults"; fi
  touch .gitignore
  cp ~/.github-repo-defaults/.gitignore .gitignore
fi
if [ ! -f README.md ]; then
   if $verbose; then echo "Custom README.md not found: attempting to copy standard README.md from ~/.github-repo-defaults"; fi
   touch README.md
   cp ~/.github-repo-defaults/README.md README.md
fi

# create and push new repository
if $verbose; then echo "Starting local git repository ..."; fi
git init
git add . 
git commit -m "$message"
  if [ $? -gt 1 ]; then echo "`basename $0`: could not commit local repository"; exit 8; fi

if $verbose; then echo "Creating Github repository '$reponame' ..."; fi
curl -s -u "$username:$apitoken" https://$hostapi/user/repos -d '{"name":"'$reponame'"}' > /dev/null 2>&1
  if [ $? -ne 0 ]; then echo "`basename $0`: curl could not perform POST"; exit 5; fi

if $verbose; then echo "Pushing local code to remote server ..."; fi
git remote add origin git@$hostname:$username/$reponame.git 2>&1
  if [ $? -ne 0 ]; then echo "`basename $0`: could not add remote repository"; exit 8; fi
git push -u origin master 2>&1
  if [ $? -ne 0 ]; then echo "`basename $0`: could not push to new remote repository"; exit 8; fi

if $verbose; then echo "`basename $0`: finished"; fi
