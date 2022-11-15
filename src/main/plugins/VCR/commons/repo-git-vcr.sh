#!/bin/bash
# github-repo-management

function operation() { 
PS3='Please choose an operation: '
options=("Create" "Invite" "Quit")
select opt in "${options[@]}"
do
    case $opt in
      "Create")
        read -p "Organization Name: " DRM_ORGNAME
        read -p "VCR Name: " DRM_REPONAME
        export DRM_ORGNAME
        export DRM_REPONAME
        create_repository
      ;;
      "Invite")
        read -p "Organization Name: " DRM_ORGNAME
        read -p "Username of invitee: " USERID
        read -p "Role of invitee: " ROLE
        read -p "VCR Name: " DRM_REPONAME
        export DRM_ORGNAME        
        export DRM_REPONAME
        invite_to_repository
      ;;
      "Quit")
        return 0
      ;;
      *) echo "invalid option $REPLY"
      ;;
    esac
done
}

create_repository() {

# check organization
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh find-organization
if [ $? -ne 0 ]; then exit $?; fi
  
# check if user is a member of the organization
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh check-organization-membership
if [ $? -ne 0 ]; then exit $?; fi

# create a gitub repository
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh create-repository
if [ $? -ne 0 ]; then exit $?; fi

# create admin team if it doesn't exists``
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh check-team "${DRM_REPONAME}_ADMIN"
  if [ $? -ne 0 ]; then
  $DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh create-team "${DRM_REPONAME}_ADMIN"
      if [ $? -ne 0 ]; then exit $?; fi
  fi

# create member team if it doesn't exists
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh check-team "${DRM_REPONAME}_MEMBER"
  if [ $? -ne 0 ]; then
  $DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh create-team "${DRM_REPONAME}_MEMBER"
      if [ $? -ne 0 ]; then exit $?; fi
  fi

# create genesis file
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh create-file
if [ $? -ne 0 ]; then exit $?; fi

# add branch protection
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh add-branch-protection
if [ $? -ne 0 ]; then exit $?; fi

# add signature protection
$DRMAN_PLUGINS_DIR/VCR/$VCR/api-$VCR-vcr.sh add-signature-protection
if [ $? -ne 0 ]; then exit $?; fi

echo "Created $DRM_REPONAME vcr successfully"

}

operation