#!/bin/bash
# gitlab-apis

HOSTNAME="gitlab.com"
HOSTAPI="gitlab.com/api/v4"
USERNAME=$(git config --global gitlab.user)
APITOKEN=$(git config --global gitlab.token)
[ -z $VERBOSE ] && VERBOSE=false

get_user_id() {
    API_TOKEN=$1
    DRM_USER_ID=$(curl -s --request GET --header "PRIVATE-TOKEN: $API_TOKEN" --header "Content-Type: application/json" https://gitlab.com/api/v4/user | jq -r '.id')
    if [ $? -ne 0 ]; then
        echo "$(basename $0): curl could not perform GET"
        return 0
    fi
    return DRM_USER_ID
}

get_org_id() {
    if [! -z $1]; then
        DRM_ORG_NAME=$1
        DRMAN_ORG_ID=curl --request POST --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$DRM_ORG_NAME | jq -r '.id'
        return DRMAN_ORG_ID
    else 
        echo "Provide org name."
        return 0
    fi
}

get_team_id() {
    if [ -z $1 || -z $2]; then
        echo "Provide org name and team name."
        return 0
    else
        DRMAN_TEAM_ID=curl --request POST --header "PRIVATE-TOKEN: $APITOKEN" "https://gitlab.com/api/v4/groups/${DRM_ORG_NAME}%2F${1}" | jq -r '.id'
        return DRMAN_TEAM_ID
    fi
}

get_repo_id() {
    if [ -z $1 || -z $2]; then
        echo "Provide org/team name and repo name."
        return 0
    else
        NAMESPACE=$1 #Org name or team name
        REPONAME=$2
        REPO_ID=curl -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" --header "Content-Type: application/json" https://gitlab.com/api/v3/projects/$DRM_ORGNAME%2F$DRM_REPONAME | jq -r '.id'
        return REPO_ID
    fi
}

# get gitlab credentials
get_gitlab_credentials() {
    [ -z $USERNAME ] && echo 'Username: '
    until [ "$USERNAME" != "" ]; do
        read USERNAME
        git config --global gitlab.user $USERNAME
    done
    [ -z $APITOKEN ] && echo 'Personal Access Token: '
    until [ "$APITOKEN" != "" ]; do
        read APITOKEN
        git config --global gitlab.token $APITOKEN
    done
    export DRM_USERID=get_user_id
}

find_organization() {
    echo "Finding organization $DRM_ORGNAME"
    status_code=$(curl -w '%{http_code}' -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" --header "Content-Type: application/json" "https://gitlab.com/api/v4/groups/groups?custom_attributes[name]=${DRM_ORGNAME}")
    export DRM_ORGID=$(curl -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" --header "Content-Type: application/json" "https://gitlab.com/api/v4/groups/groups?custom_attributes[name]=${DRM_ORGNAME}") | jq -r '.[0] | .id'
    if [ $status_code -ne 200 ]; then
        if $VERBOSE; then echo "Cannot find organization"; fi
        return 5
    fi
    return 0
}

#list organization repositories
list_organization_repositories() {
    DRM_ORG_ID=get_org_id $DRM_ORGNAME
    curl -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" --header "Content-Type: application/json" "https://gitlab.com/api/v4/groups/$DRM_ORG_ID/projects"
    if [ $? -ne 0 ]; then
        echo "$(basename $0): curl could not perform GET"
        return 5
    fi
    return 0
}

create_organization() {
    echo "Creating gitlab $DRM_ORGNAME organization ... "
    status_code=$(curl -w '%{http_code}' -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" --header "Content-Type: application/json" "https://gitlab.com/api/v4/groups?name=$DRM_ORGNAME&path=$DRM_ORGNAME")
    if [ $status_code -ne 201 ]; then
        if $VERBOSE; then echo "Only an enterprise account can create an organization"; fi
        return 5
    fi
    return 0
}

check_organization_membership() {
    echo "Verifying $DRM_ORGNAME organization membership"
    DRM_USER_ID=get_user_id
    status_code=$(curl -w '%{http_code}' -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" --header "Content-Type: application/json" "https://gitlab.com/api/v4/groups/$DRM_ORGID/members/$DRM_USER_ID")
    if [ $status_code -ne 204 ]; then
        if $VERBOSE; then echo "$DRM_ORGNAME Organization membership not found for $USERNAME"; fi
        return 5
    fi
    return 0
}

create_repository() {
    echo "Creating $DRM_ORGNAME organization repository $DRM_REPONAME ..."
    DRM_ORG_ID=get_org_id $DRM_ORGNAME
    status_code=$(curl -w '%{http_code}' -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" --header "Content-Type: application/json" https://gitlab.com/api/v4/projects?name=$DRM_REPONAME&namespace_id=$DRM_ORG_ID)
    if [ $status_code -ne 201 ]; then
        if $VERBOSE; then echo "$(basename $0): curl could not create $DRM_ORGNAME organization repository $DRM_REPONAME"; fi
        return 5
    fi
    return 0
}

invite_to_organization() {
    ORG_ID=get_org_id $1
    status_code=$(curl -w '%{http_code}' -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" --data "email=$2&access_level=30" https://gitlab.com/api/v4/groups/$ORG_ID/invitations)
    if [ $status_code -ne 201 ]; then
        if $VERBOSE; then echo "$(basename $0): curl could not create $DRM_ORGNAME organization invitation for $2"; fi
        return 5
    fi
    return 0
}

set_organization_role() {
    case $2 in 
    "No access")
        access_level=0
    ;;
    "Minimal access")
        access_level=5
    ;;
    "Guest")
        access_level=10
    ;;
    "Reporter")
        access_level=20
    ;;
    "Developer")
        access_level=30
    ;;
    "Maintainer")
        access_level=40
    ;;
    "Owner")
        access_level=50
    ;;
    *)
        access_level=30
        echo "Default level: 30"
    ;;
    esac
    DRM_USER_ID=$(curl -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/users?username=$1 | jq '.[].id')
    DRMAN_ORG_ID=get_org_id $DRM_ORGNAME
    status_code=$(curl -w '%{http_code}' -s --request PUT --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$DRM_ORG_ID/members/$DRM_USER_ID?access_level=$access_level)
    if [ $status_code -ne 200 ]; then
        if $VERBOSE; then echo "$(basename $0): curl could not set $DRM_ORGNAME organization $3 membership for $2"; fi
        return 5
    fi
    return 0
}

add_branch_protection() {
    echo "Adding branch protection to repository $DRM_REPONAME ..."
    DRM_REPO_ID=get_repo_id $DRM_ORGNAME $DRM_REPONAME
    status_code=$(curl -w '%{http_code}' -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" "https://gitlab.com/api/v4/projects/$DRM_REPO_ID/protected_branches?name=*&push_access_level=30&merge_access_level=30&unprotect_access_level=40")
    if [ $status_code -ne 200 ]; then
        if $VERBOSE; then echo "basename $status_code: status_code: $status_code Failed to update branch protection"; fi
        return 5
    fi
    return 0
}

add_signature_protection() {
    return 0
}

create_team() {
   echo "Creating $1 team to $DRM_ORGNAME organization ..."
   find_organization
    case $1 in
        "${DRM_REPONAME}_ADMIN" | "ADMIN")
        name=$1
        description='Administrative team'
        default_branch_protection=3
        path="${DRM_ORGNAME}%2F${name}"
        parent_id=$DRM_ORGID
        ;;
        *)
        name=$1
        description='Membership team'
        default_branch_protection=2
        path="${DRM_ORGNAME}2%F${name}"
        parent_id=$DRM_ORGID  
        ;;
    esac
    curl --request POST --header "PRIVATE-TOKEN: $APITOKEN" \
    --header "Content-Type: application/json" \
    --data '{"path": '$path', "name": '$name', "parent_id": '$parent_id', "description": '$description' }' \
    "https://gitlab.com/api/v4/groups/"
    if [ $status_code -ne 201 ]; then if $DRM_VERBOSE; then echo "basename $0: status_code: $status_code Failed to create $1 team"; fi; return 5; fi
    return 0
}

list_teams() {
    if [ -z $1 ]; then
        DRM_ORG_ID=get_org_id $DRM_ORGNAME
        curl --request POST --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$DRM_ORG_ID/subgroups
    else
        curl --request POST --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$DRM_ORGNAME%2F$1
    fi
    return 0
}

check_team() {
    status_code=$(curl -w '%{http_code}' -s --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$DRM_ORGNAME%2F$1)
    if [ $status_code -ne 200 ]; then
        if $VERBOSE; then echo "status_code: $status_code $1 team not found"; fi
        return 5
    fi
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
    team_id=get_team_id $1
    if [$team_id -eq 0]; then
        echo "Team not found"
        return 5
    fi
    status_code=$(curl -w '%{http_code}' -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/projects?name=$2&namespace_id=$team_id)
    if [ $status_code -ne 204 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
 }

list_team_repository() {
    curl --request GET --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$DRM_ORGNAME%2f$1/projects
}

remove_team_repository() {
    TEAMNAME=$1
    REPONAME=$2
    REPO_ID=get_repo_id $TEAMNAME $REPONAME
    status_code=$(curl -w '%{http_code}' -s --request DELETE --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/projects/$REPO_ID)
    if [ $status_code -ne 204 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

add_team_member() {
    case $3 in 
    "No access")
        access_level=0
    ;;
    "Minimal access")
        access_level=5
    ;;
    "Guest")
        access_level=10
    ;;
    "Reporter")
        access_level=20
    ;;
    "Developer")
        access_level=30
    ;;
    "Maintainer")
        access_level=40
    ;;
    "Owner")
        access_level=50
    ;;
    *)
        access_level=30
        echo "Default level: 30"
    ;;
    esac
    USER2_ID=$(curl -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/users?username=$2 | jq '.[].id')
    TEAM_ID=get_team_id $1
    if [TEAM_ID -eq 0]; then
        echo "Incorrect team name"
        return 5
    fi
    status_code=$(curl -w '%{http_code}' -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$TEAM_ID/members?user_id=$USER2_ID&access_level=$access_level)
    if [ $status_code -ne 200 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

list_team_member() {
    TEAM_ID=get_team_id $1
    if [TEAM_ID -eq 0]; then
        echo "Incorrect team name"
        return 5
    fi
    curl -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$TEAM_ID/members/all
    return 0    
}

remove_team_member() {
    USER2_ID=$(curl -s --request GET --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/users?username=$2 | jq '.[].id')
    TEAM_ID=get_team_id $1
    if [TEAM_ID -eq 0]; then
        echo "Incorrect team name"
        return 5
    fi
    status_code=$(curl -w '%{http_code}' -s --request DELETE --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/groups/$TEAM_ID/members/$USER2_ID)
    if [ $status_code -ne 204 ]; then if $DRM_VERBOSE; then echo "status_code: $status_code $1 team not found"; fi; return 5; fi
    return 0
}

create_file() {
    DRM_REPO_ID=get_repo_id $DRM_ORGNAME $DRM_REPONAME
    status_code=$(curl -w '%{http_code}' -s --request POST --header "PRIVATE-TOKEN: $APITOKEN" --data '{"branch": "master", "content": "VGhpcyBpcyBhIFZDUg==", "commit_message": "genesis commit"}' https://gitlab.com/api/v4/projects/$DRM_REPO_ID/repository/files/contents%2FREADME.md)
    if [ $status_code -ne 201 ]; then
        if $VERBOSE; then echo "status_code: $status_code $1 team not found"; fi
        return 5
    fi
    return 0
}

read_file() {
    echo "Reading $1 from $DRM_ORGNAME organization and $DRM_REPONAME repository"
    DRM_REPO_ID=get_repo_id $DRM_ORGNAME $DRM_REPONAME
    curl --request GET --header "PRIVATE-TOKEN: $APITOKEN" https://gitlab.com/api/v4/projects/$DRM_REPO_ID/repository/files/$1.json
    if [ $? -ne 0 ]; then
        echo "$(basename $0): curl could not perform GET"
        return 5
    fi
    echo ""
    return 0
}

case $1 in
"get-gitlab-credentials")
    get_gitlab_credentials
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
"create-repository")
    create_repository
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
