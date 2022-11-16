# main menu

function operation() {
    echo "Welcome to $VCR VCR!"
    PS3="Please choose an operation: "
    items=("Organization" "VCR" "DID" "Quit")
    select opt in "${items[@]}"
    do
        case $opt in
            "Organization")
                $DRMAN_PLUGINS_DIR/VCR/commons/org-git-vcr.sh
                ;;
            "VCR")
                $DRMAN_PLUGINS_DIR/VCR/commons/repo-git-vcr.sh
                ;;
            "DID")
                $DRMAN_PLUGINS_DIR/VCR/commons/did-git-vcr.sh
                ;;
            "Quit")
                echo "Done here! Taking you to VCR Selection back."
                break
                ;;
            *) echo "invalid option $REPLY" ;;
        esac
    done
}

operation