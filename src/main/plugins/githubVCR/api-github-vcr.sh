#!/bin/bash
# github-apis

HOSTNAME="github.com"
HOSTAPI="api.github.com"
USERNAME=`git config --global github.user`
APITOKEN=`git config --global github.token`
[ -z $DRM_VERBOSE ] && DRM_VERBOSE=false
 
# get github credentials
get_github_credentials() {
    [ -z $USERNAME ] && echo 'Username: '
    until [ "$USERNAME" != "" ]; do read USERNAME ; git config --global github.user $USERNAME; done
    [ -z $APITOKEN ] && echo 'Apitoken: '
    until [ "$APITOKEN" != "" ]; do read APITOKEN ; git config --global github.token $APITOKEN; done
}

#list organization repositories
list_organization_repositories() {
    curl -s -u "$USERNAME:$APITOKEN" https://$HOSTAPI/orgs/$DRM_ORGNAME/repos | grep "\"full_name\":" | cut -d \" -f 4 2>&1
        if [ $? -ne 0 ]; then echo "`basename $0`: curl could not perform GET"; return 5; fi
    return 0
}

find_organization() {
    echo "Finding organization $DRM_ORGNAME"
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -H "Accept: application/vnd.github.v3+json" https://$HOSTAPI/orgs/$DRM_ORGNAME)
    if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "Cannot find organization"; fi; return 5; fi
    return 0
}

create_organization() {
    echo "Creating github $DRM_ORGNAME organization ... "
    status_code=$(curl -u "$USERNAME:$APITOKEN" -w '%{http_code}' -s -o /dev/null -X POST -H "Accept: application/vnd.github.v3+json" https://$HOSTAPI/admin/organizations -d '{"login":"'$DRM_ORGNAME'","profile_name":"'$DRM_ORGNAME'","admin":"'$USERNAME'"}')
    if [ $status_code -ne 201 ]; then if $DRM_VERBOSE; then echo "Only an enterprise account can create an organization"; fi; return 5; fi
    return 0
}

check_organization_membership() {
    echo "Verifying $DRM_ORGNAME organization membership"
    status_code=$(curl -u "$USERNAME:$APITOKEN" -w '%{http_code}' -s -o /dev/null -H "Accept: application/vnd.github.v3+json" https://$HOSTAPI/orgs/$DRM_ORGNAME/members/$USERNAME)
    if [ $status_code -ne 204 ]; then if $DRM_VERBOSE; then echo "$DRM_ORGNAME Organization membership not found for $USERNAME"; fi; return 5; fi
    return 0
}

create_repository() {
    echo "Creating $DRM_ORGNAME organization repository $DRM_REPONAME ..."
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$USERNAME:$APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/repos -d '{"name":"'$DRM_REPONAME'"}')
        if [ $status_code -ne 201 ]; then if $DRM_VERBOSE; then echo "`basename $0`: curl could not create $DRM_ORGNAME organization repository $DRM_REPONAME"; fi; return 5; fi
    return 0
}

invite_to_organization() {
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$USERNAME:$APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/invitations -d '{"email":"'$2'","role":"'$3'"}')
        if [ $status_code -ne 201 ]; then if $DRM_VERBOSE; then echo "`basename $0`: curl could not create $DRM_ORGNAME organization invitation for $2"; fi; return 5; fi
    return 0
}

set_organization_role() {
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -u "$USERNAME:$APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/memberships/$2 -d '{"role":"'$3'"}')
        if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "`basename $0`: curl could not set $DRM_ORGNAME organization $3 membership for $2"; fi; return 5; fi
    return 0
}

add_branch_protection() {
    echo "Adding branch protection to repository $DRM_REPONAME ..."
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -X PUT -H "Authorization: token $APITOKEN" https://$HOSTAPI/repos/$DRM_ORGNAME/$DRM_REPONAME/branches/main/protection \
    -d '{"required_status_checks":{"strict":true, "contexts": []},"enforce_admins":true,"required_pull_request_reviews":{"require_code_owner_reviews":true,"required_approving_review_count":1},"restrictions":null,"required_linear_history":true,"required_conversation_resolution":true}' \
    )
    if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "basename $status_code: status_code: $status_code Failed to update branch protection"; fi; return 5; fi
    return 0
}

add_signature_protection() {
    echo "Adding signature protection to repository $DRM_REPONAME ..."
    status_code=$(curl \
    -w '%{http_code}' -s -o /dev/null -X POST -H "Authorization: token $APITOKEN" https://api.github.com/repos/$DRM_ORGNAME/$DRM_REPONAME/branches/main/protection/required_signatures)
    if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "basename $0: status_code: $status_code Failed to add signature protection"; fi; return 5; fi
    return 0
}

create_team() {
    echo "Creating $1 team to $DRM_ORGNAME organization ..."
    case $1 in
        "${DRM_REPONAME}_ADMIN" | "ADMIN")
            name=$1
            description='Administrative team'
            permission='push'
            privacy='secret'
        ;;
        *)
            name=$1
            description='Membership team'
            permission='pull'
            privacy='closed'
        ;;
    esac
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -H "Authorization: token $APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/teams \
    -d '{"name":"'"$name"'","description":"'"$description"'","permission":"'"$permission"'","privacy":"'"$privacy"'","repo_names": ["'"${DRM_ORGNAME}/${DRM_REPONAME}"'"]}')
    if [ $status_code -ne 201 ]; then if $DRM_VERBOSE; then echo "basename $0: status_code: $status_code Failed to create $1 team"; fi; return 5; fi
    return 0
}

list_teams() {
    if [ ! -z $1 ]
    then
        curl -H "Authorization: token $APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/teams/$1
    else
        curl -H "Authorization: token $APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/teams
    fi
}

check_team() {
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -H "Authorization: token $APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/teams/$1)
    if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

add_team_repository() {
    case $1 in
    "${DRM_REPONAME}_ADMIN" | "ADMIN")
        permission='push'
    ;;
    "${DRM_REPONAME}_MEMBER" | "MEMBER")
        permission='pull'
    ;;
    esac
    status_code=$(curl -w '%{http_code}' -X PUT -s -o /dev/null -H "Authorization: token $APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/teams/$1/repos/$USERNAME/$2 -d '{"permission":"'"$permission"'"}' )
    if [ $status_code -ne 204 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

list_team_repository() {
    curl -H "Authorization: token $APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/teams/$1/repos
}

remove_team_repository() {
    status_code=$(curl -w '%{http_code}' -X DELETE -s -o /dev/null -H "Authorization: token $APITOKEN" https://api.github.com/orgs/$DRM_ORGNAME/teams/$1/repos/$USERNAME/$2)
    if [ $status_code -ne 204 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

add_team_member() {
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -H "Authorization: token $APITOKEN"  https://api.github.com/orgs/$DRM_ORGNAME/teams/$1/memberships/$2 -d '{"role": "'"$3"'"}')
    if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

list_team_member() {
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -H "Authorization: token $APITOKEN"  https://api.github.com/orgs/$DRM_ORGNAME/teams/$1/members -d '{"role": "'"$3"'"}')
    if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0    
}

remove_team_member() {
    status_code=$(curl -w '%{http_code}' -X DELETE -s -o /dev/null -H "Authorization: token $APITOKEN"  https://api.github.com/orgs/$DRM_ORGNAME/teams/$1/memberships/$2)
    if [ $status_code -ne 204 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

create_file() {
    status_code=$(curl -w '%{http_code}' -s -o /dev/null -X PUT -H "Authorization: token $APITOKEN" https://api.github.com/repos/$DRM_ORGNAME/$DRM_REPONAME/contents/README.md \
  -d '{"message":"genesis commit","content":"VGhpcyBpcyBhIFZDUg=="}')
    if [ $status_code -ne 201 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

read_file() {
    echo "Reading $1 from $DRM_ORGNAME orgnaization and $DRM_REPONAME repository"
    curl -H "Authorization: token $APITOKEN" https://raw.githubusercontent.com/$DRM_ORGNAME/$DRM_REPONAME/master/"$1.json"
    # echo $(curl -H "Authorization: token $APITOKEN" https://api.github.com/repos/$DRM_ORGNAME/$DRM_REPONAME/contents/"$1.json") | jq -r '.content' | base64 --decode 
      if [ $? -ne 0 ]; then echo "`basename $0`: curl could not perform GET"; return 5; fi
    echo ""
    return 0
}

case $1 in
    "get-github-credentials")
        get_github_credentials
    ;;
    # organizations
    "find-organization")
        find_organization
    ;;
    "create-organization")
        create_organization
    ;;
    "check-organization-membership")
        check_organization_membership
    ;;
    "invite-to-organization")
        invite_to_organization $2 $3
    ;;
    "set-organization-role")
        set_organization_role $2 $3
    ;;
    # teams
    "create-team")
        create_team $2
    ;;
    "add-team-repository")
        add_team_repository $2 $3
    ;;
    "list-team-repository")
        list_team_repository $2
    ;;
    "remove-team-repository")
        remove_team_repository $2 $3
    ;;
    "add-team-member")
        add_team_member $2 $3 $4 
    ;;
    "list-team-member")
        list_team_member $2
    ;;
    "remove-team-member")
        remove_team_member $2 $3 $4 
    ;;
    "list-teams")
        list_teams $2
    ;;
    "check-team")
        check_team $2
    ;;
    # repositories
    "list-organization-repositories")
        list_organization_repositories
    ;;
    "find-repository")
        find_repository
    ;;
    "create-repository")
        create_repository
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
    "create-file")
        create_file
    ;;
    "read-file")
        read_file $2
    ;;
esac