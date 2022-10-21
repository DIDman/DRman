#!/bin/bash
# github-org-management

function operation() {
    PS3='Please choose an operation: '
    options=("Create" "Invite" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
        "Create")
            # get organization name
            read -p "Organization Name: " ORGNAME
            export ORGNAME
            create_organization
            ;;
        "Invite")
            read -p "Organization Name: " ORGNAME
            read -p "Username of invitee: " USERID
            read -p "Role of invitee: " ROLE
            export ORGNAME
            invite_to_organization
            ;;
        "Quit")
            return 0
            ;;
        *)
            echo "invalid option $REPLY"
            ;;
        esac
    done
}

create_organization() {
    # create an organization if it doesn't exists
    $DRMAN_DIR/helper/Github/api-$VCR-vcr.sh find-organization
    if [ $? -ne 0 ]; then
        $DRMAN_DIR/helper/api-$VCR-vcr.sh create-organization
        echo "Organization $ORGNAME created successfully"
        if [ $? -ne 0 ]; then exit $?; fi
    else
        echo "Organization $ORGNAME already exists"
    fi
}

invite_to_organization() {
    $DRMAN_DIR/helper/Github/api-$VCR-vcr.sh invite-to-organization $USERID $ROLE
}

operation
