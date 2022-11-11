#!/bin/bash
# github-did-management

function operation() { 
PS3='Please choose an operation: '
options=("Resolve" "Quit")
select opt in "${options[@]}"
do
    case $opt in
      "Resolve")
        # get organization name
        read -p "DID: " DID
        parse_did
        resolve_did
      ;;
      "Quit")
        return 0
      ;;
      *) echo "invalid option $REPLY"
      ;;
    esac
done
}

# methods
parse_did() {
    readarray -d : -t didarr <<< $DID
    DRM_ORGNAME=${didarr[2]}
    DRM_REPONAME=${didarr[3]}
    USERID=${didarr[4]}
    ID=${didarr[5]}
    export DRM_VERBOSE
    export DRM_ORGNAME
    export DRM_REPONAME
    # export USERID
    # export ID
}

resolve_did() {
    $DRMAN_DIR/helper/api-github-vcr.sh read-file "$USERID/$ID"
}

operation