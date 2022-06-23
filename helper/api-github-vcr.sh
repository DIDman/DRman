#!/bin/bash
# github-authenticate-user

reponame=`basename $(pwd)`
hostname="github.com"
hostapi="api.github.com"
export username=`git config --global github.user`
apitoken=`git config --global github.token`
[ -z $verbose ] && verbose=false
 
# get github credentials
get_github_credentials() {
    [ -z $username ] && echo 'Username: '
    until [ "$username" != "" ]; do read username; git config --global username; done
    [ -z $apitoken ] && echo 'Apitoken: '
    until [ "$apitoken" != "" ]; do read apitoken; git config --global apitoken; done
}

#list organization repositories
list_organization_repositories() {
    get_github_credentials
    curl -s -u "$username:$apitoken" https://$hostapi/orgs/$1/repos | grep "\"full_name\":" | cut -d \" -f 4 2>&1
        if [ $? -ne 0 ]; then echo "`basename $0`: curl could not perform GET"; return 5; fi
    return 0
}

find_organization() {
    if $verbose; then echo "Finding organization $orgname"; fi
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -H "Accept: application/vnd.github.v3+json" https://$hostapi/orgs/$1)
    if [ $status_code -ne 200 ]; then if $verbose; then echo "Cannot find organization"; fi; return 5; fi
    return 0
}

create_organization() {
    if $verbose;  then echo "Creating github $orgname organization ... "; fi
    status_code=$(curl -u "$username:$apitoken" -w '%{http_code}' -s -o /dev/null -X POST -H "Accept: application/vnd.github.v3+json" https://$hostapi/admin/organizations -d '{"login":"$orgname","profile_name":"$orgname","admin":"$username"}')
    if [ $status_code -ne 201 ]; then if $verbose; then echo "Only an enterprise account can create an organization"; fi; return 5; fi
    return 0
}

check_organization_membership() {
    get_github_credentials
    if $verbose; then echo "Verifying $orgname organization membership"; fi
    status_code=$(curl -u "$username:$apitoken" -w '%{http_code}' -s -o /dev/null -H "Accept: application/vnd.github.v3+json" https://$hostapi/orgs/$1/members/$username)
    if [ $status_code -ne 204 ]; then return 5; fi
    return 0
}

create_repository() {
    if $verbose; then echo "Creating $orgname organization repository $reponame ..."; fi
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$username:$apitoken" https://api.github.com/orgs/$1/repos -d '{"name":"'$2'"}')
        if [ $status_code -ne 201 ]; then echo "`basename $0`: curl could not create $1 organization repository $2"; return 5; fi
    return 0
}

invite_user_organization() {
    get_github_credentials
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$username:$apitoken" https://api.github.com/orgs/$1/invitations -d '{"email":"$2","role":"$3"}')
        if [ $status_code -ne 201 ]; then echo "`basename $0`: curl could not create $1 organization invitation for $2"; return 5; fi
    return 0
}

set_organization_role() {
    get_github_credentials
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$username:$apitoken" https://api.github.com/orgs/$1/memberships/$2 -d '{"role":"$3"}')
        if [ $status_code -ne 200 ]; then echo "`basename $0`: curl could not set $1 organization $3 membership for $2"; return 5; fi
    return 0
}


case $1 in
    "list-organization-repositories")
        list_organization_repositories $2
    ;;
    "find-organization")
        find_organization $2
    ;;
    "create-organization")
        create_organization $2
    ;;
    "check-organization-membership")
        check_organization_membership $2
    ;;
    "find-repository")
        find_repository $2 $3
    ;;
    "create-repository")
        create_repository $2 $3
    ;;
    "invite-member-organization")
        invite_user_organization $2 $3 "direct_member"
    ;;
    "invite-admin-organization")
        invite_user_organization $2 $3 "admin"
    ;;
    "set-organization-role")
        set_organization_role $2 $3 $4
    ;;
    "set-repository-role")
        set_repository_role $2 $3 $4
    ;;
esac