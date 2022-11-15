#!/bin/bash
# github-did-management

WALLET_PATH=$DRMAN_DIR/wallet

function operation() { 
PS3='Please choose an operation: '
options=("Create" "Update" "Resolve" "Quit")
select opt in "${options[@]}"
do
    case $opt in
      "Create")
        read -p "Key identifier: " ALIAS
        create_did
      ;;
      "Update")
        read -p "Enter identifier: " uuid
        read -p "Key identifier: " ALIAS
        update_did
      ;;
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
create_did() {
  # wallet for did plugin

  # method specific uuid
  uuid=$(uuidgen)
  mkdir -p $WALLET_PATH/$uuid
  
  # key generation
  key_types=("rsa" "ed25519" "ecdsa")
  select opt in ${key_types[@]}
  do
      ssh-keygen -f $WALLET_PATH/$uuid/$ALIAS -t $opt -q -N ""
      verkey=$(cat $WALLET_PATH/$uuid/$ALIAS.pub | base64)
      DID_VERKEY="{\"did\":\"$uuid\",\"verkey\":[\"$verkey\"]}"
      echo $DID_VERKEY | jq .
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
  keys=()
  for f in $WALLET_PATH/$uuid/*.pub; do
      keys+=($(cat $f | base64))
  done
  printf -v verkey '%s,' "${keys[@]}"
  DID_VERKEY="{\"did\":\"$uuid\",\"verkey\":[\"${verkey::-1}\"]}"
  echo $DID_VERKEY | jq .
  # verkey=$(cat $WALLET_PATH/$uuid/$ALIAS.pub | base64)
}

update_did() {
  if [[ -d $WALLET_PATH/$uuid ]] && [[ ! -f $WALLET_PATH/$uuid/$ALIAS ]]; then
    key_types=("rsa" "ed25519" "ecdsa")
    select opt in ${key_types[@]}
    do
        ssh-keygen -f $WALLET_PATH/$uuid/$ALIAS -t $opt -q -N ""
        verkey=$(cat $WALLET_PATH/$uuid/$ALIAS.pub | base64)
        DID_VERKEY="{\"did\":\"$uuid\",\"verkey\":[\"$verkey\"]}"
        echo $DID_VERKEY | jq .
    done
  else
    echo "Did not found or key already exists"
  fi
}

operation