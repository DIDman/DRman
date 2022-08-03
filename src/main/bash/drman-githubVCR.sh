# main menu

function __drm_githubVCR() {
    $DRMAN_DIR/helper/api-github-vcr.sh get_github_credentials
    PS3='Please choose an operation: '
    options=("Organization" "VCR" "DID" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Organization")
                set_env
                $DRMAN_DIR/helper/org-github-vcr.sh
            ;;
            "VCR")
                set_env
                $DRMAN_DIR/helper/repo-github-vcr.sh               
            ;;
            "DID")
                $DRMAN_DIR/helper/did-github-vcr.sh  
            ;;
            "Quit")
                exit 0
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}