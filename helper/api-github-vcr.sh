#!/bin/bash
# github-authenticate-user

HOSTNAME="github.com"
HOSTAPI="api.github.com"
USERNAME=`git config --global github.user`
APITOKEN=`git config --global github.token`
[ -z $VERBOSE ] && VERBOSE=false
 
# get github credentials
get_github_credentials() {
    [ -z $USERNAME ] && echo 'Username: '
    until [ "$USERNAME" != "" ]; do read USERNAME ; git config --global github.user $USERNAME; done
    [ -z $APITOKEN ] && echo 'Apitoken: '
    until [ "$APITOKEN" != "" ]; do read APITOKEN ; git config --global github.token $APITOKEN; done
}

#list organization repositories
list_organization_repositories() {
    get_github_credentials
    curl -s -u "$USERNAME:$APITOKEN" https://$HOSTAPI/orgs/$ORGNAME/repos | grep "\"full_name\":" | cut -d \" -f 4 2>&1
        if [ $? -ne 0 ]; then echo "`basename $0`: curl could not perform GET"; return 5; fi
    return 0
}

find_organization() {
    if $VERBOSE; then echo "Finding organization $ORGNAME"; fi
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -H "Accept: application/vnd.github.v3+json" https://$HOSTAPI/orgs/$ORGNAME)
    if [ $status_code -ne 200 ]; then if $VERBOSE; then echo "Cannot find organization"; fi; return 5; fi
    return 0
}

create_organization() {
    get_github_credentials
    if $VERBOSE;  then echo "Creating github $ORGNAME organization ... "; fi
    status_code=$(curl -u "$USERNAME:$APITOKEN" -w '%{http_code}' -s -o /dev/null -X POST -H "Accept: application/vnd.github.v3+json" https://$HOSTAPI/admin/organizations -d '{"login":"$ORGNAME","profile_name":"$ORGNAME","admin":"$USERNAME"}')
    if [ $status_code -ne 201 ]; then if $VERBOSE; then echo "Only an enterprise account can create an organization"; fi; return 5; fi
    return 0
}

check_organization_membership() {
    get_github_credentials
    if $VERBOSE; then echo "Verifying $ORGNAME organization membership"; fi
    status_code=$(curl -u "$USERNAME:$APITOKEN" -w '%{http_code}' -s -o /dev/null -H "Accept: application/vnd.github.v3+json" https://$HOSTAPI/orgs/$ORGNAME/members/$USERNAME)
    if [ $status_code -ne 204 ]; then if $VERBOSE; then echo "$ORGNAME Organization membership not found for $USERNAME"; fi; return 5; fi
    return 0
}

create_repository() {
    get_github_credentials
    if $VERBOSE; then echo "Creating $ORGNAME organization repository $REPONAME ..."; fi
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$USERNAME:$APITOKEN" https://api.github.com/orgs/$ORGNAME/repos -d '{"name":"'$REPONAME'"}')
        if [ $status_code -ne 201 ]; then if $VERBOSE; then echo "`basename $0`: curl could not create $ORGNAME organization repository $REPONAME"; fi; return 5; fi
    return 0
}

invite_user_organization() {
    get_github_credentials
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$USERNAME:$APITOKEN" https://api.github.com/orgs/$ORGNAME/invitations -d '{"email":"$2","role":"$3"}')
        if [ $status_code -ne 201 ]; then if $VERBOSE; then echo "`basename $0`: curl could not create $ORGNAME organization invitation for $2"; fi; return 5; fi
    return 0
}

set_organization_role() {
    get_github_credentials
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$USERNAME:$APITOKEN" https://api.github.com/orgs/$ORGNAME/memberships/$2 -d '{"role":"$3"}')
        if [ $status_code -ne 200 ]; then if $VERBOSE; then echo "`basename $0`: curl could not set $ORGNAME organization $3 membership for $2"; fi; return 5; fi
    return 0
}

add_branch_protection() {
    get_github_credentials
    if $VERBOSE; then echo "Adding branch protection to repository $REPONAME ..."; fi
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -X PUT -H "Authorization: token $APITOKEN" https://$HOSTAPI/repos/$ORGNAME/$REPONAME/branches/master/protection \
    -d '{"required_status_checks":{"strict":true, "contexts": []},"enforce_admins":true,"required_pull_request_reviews":{"require_code_owner_reviews":true,"required_approving_review_count":2},"restrictions":null,"required_linear_history":true,"required_conversation_resolution":true}' \
    )
    if [ $status_code -ne 200 ]; then if $VERBOSE; then echo "basename $status_code: status_code: $status_code Failed to update branch protection"; fi; return 5; fi
    return 0
}

add_signature_protection() {
    get_github_credentials
    if $VERBOSE; then echo "Adding signature protection to repository $REPONAME ..."; fi
    status_code=$(curl \
    -w '%{http_code}' -s -o /dev/null -X POST -H "Authorization: token $APITOKEN" https://api.github.com/repos/$ORGNAME/$REPONAME/branches/master/protection/required_signatures)
    if [ $status_code -ne 200 ]; then if $VERBOSE; then echo "basename $0: status_code: $status_code Failed to add signature protection"; fi; return 5; fi
    return 0
}

case $1 in
    "list-organization-repositories")
        list_organization_repositories
    ;;
    "find-organization")
        find_organization
    ;;
    "create-organization")
        create_organization
    ;;
    "check-organization-membership")
        check_organization_membership
    ;;
    "find-repository")
        find_repository
    ;;
    "create-repository")
        create_repository
    ;;
    "invite-member-organization")
        invite_user_organization $2 "direct_member"
    ;;
    "invite-admin-organization")
        invite_user_organization $2 "admin"
    ;;
    "set-organization-role")
        set_organization_role $2 $3
    ;;
    "set-repository-role")
        set_repository_role $2 $3
    ;;
    "add-branch-protection")
        add_branch_protection
    ;;
    "add-signature-protection")
        add_signature_protection
    ;;
esac