# main menu

function __drm_did() {
    PS3='Please choose a DID method: '
    options=("did:sov" "did:git")
    select opt in "${options[@]}"
    do
        case $opt in
            "did:sov")
                $DRMAN_PLUGINS_DIR/DID/did-sov.sh
            ;;
            "did:git")
                $DRMAN_PLUGINS_DIR/DID/did-git.sh               
            ;;
            "Quit")
                exit 0
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}