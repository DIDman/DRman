#!/bin/bash
# github-team-management

function operation() { 
PS3='Please choose an operation: '
options=("Create Team" "List Teams" "Get Team" "Add Repository" "Get Repositories" "Remove Repository" "Add member" "List members" "Remove member")
select opt in "${options[@]}"
do
  case $opt in
    "Create Team")
      # get team name
      read -p "Team Name: " TEAMNAME
      create_team
    ;;
    "List Teams")
      $DRMAN_DIR/helper/api-github-vcr.sh list-teams
    ;;
    "Get Team")
      read -p "Team Name: " TEAMNAME
      $DRMAN_DIR/helper/api-github-vcr.sh list-teams $TEAMNAME
    ;;
    "Add Repository")
      read -p "Team Name: " TEAMNAME
      read -p "Repo Name: " REPONAME
      $DRMAN_DIR/helper/api-github-vcr.sh add-team-repository $TEAMNAME $REPONAME
    ;;
    "Get Repositories")
      read -p "Team Name: " TEAMNAME
      read -p "Repo Name: " REPONAME 
      $DRMAN_DIR/helper/api-github-vcr.sh get-team-repository $TEAMNAME $REPONAME
    ;;
    "Remove Repository")
      read -p "Team Name: " TEAMNAME
      read -p "Repo Name: " REPONAME 
      $DRMAN_DIR/helper/api-github-vcr.sh remove-team-repository $TEAMNAME $REPONAME
    ;;
    "Add member")
      read -p "Team Name: " TEAMNAME
      read -p "User Name: " USERNAME
      read -p "Role: " ROLE
      $DRMAN_DIR/helper/api-github-vcr.sh add-team-member $TEAMNAME $REPONAME $ROLE  
    ;;
    "List members")
      read -p "Team Name: " TEAMNAME
      $DRMAN_DIR/helper/api-github-vcr.sh add-team-member $TEAMNAME $REPONAME   
    ;;
    "Remove member")
      read -p "Team Name: " TEAMNAME
      read -p "User Name: " USERNAME
      $DRMAN_DIR/helper/api-github-vcr.sh remove-team-member $TEAMNAME $REPONAME
    ;;
    "Quit")
      return 0
    ;;
    *) echo "invalid option $REPLY"
    ;;
  esac
done
}

create_team() {
  # create a team if it doesn't exists
  $DRMAN_DIR/helper/api-github-vcr.sh check-team $TEAMNAME
  if [ $? -ne 0 ]; then
      $DRMAN_DIR/helper/api-github-vcr.sh create-team $TEAMNAME
      echo "Team $TEAMNAME created successfully"
      if [ $? -ne 0 ]; then exit $?; fi
  else echo "Team $TEAMNAME already exists"
  fi
}

invite_to_organization() {
  $DRMAN_DIR/helper/api-github-vcr.sh invite-to-organization $USERID $ROLE
}

operation