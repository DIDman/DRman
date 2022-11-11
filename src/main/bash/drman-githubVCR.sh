# main menu

function __drm_githubVCR() {
    $DRMAN_DIR/helper/api-github-vcr.sh get_github_credentials
    PS3='Please choose an operation: '
    options=("Organization" "VCR" "Teams" "DID" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Organization")
                $DRMAN_DIR/helper/org-github-vcr.sh
            ;;
            "VCR")
                $DRMAN_DIR/helper/repo-github-vcr.sh               
            ;;
            "DID")
                $DRMAN_DIR/helper/did-github-vcr.sh  
            ;;
            "Teams")
                bash $DRMAN_DIR/helper/team-github-vcr.sh
            ;;
            "Quit")
                exit 0
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}