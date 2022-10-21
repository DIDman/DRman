# main menu

function __drm_gitVCR() {
    echo "Welcome to Github VCR!"
    PS3="Please choose an operation: "
    items=("Organization" "VCR" "DID" "Quit")
    select opt in "${items[@]}"
    do
        case $opt in
            "Organization")
                $DRMAN_DIR/helper/org-git-vcr.sh
                ;;
            "VCR")
                $DRMAN_DIR/helper/repo-git-vcr.sh
                ;;
            "DID")
                $DRMAN_DIR/helper/did-git-vcr.sh
                ;;
            "Quit")
                echo "Done here! Taking you to VCR Selection back."
                break
                ;;
            *) echo "invalid option $REPLY" ;;
        esac
    done
}