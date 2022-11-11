# main menu

function __drm_githubVCR() {
    $DRMAN_PLUGINS_DIR/githubVCR/api-github-vcr.sh get-github-credentials
    PS3='Please choose an operation: '
    options=("Organization" "VCR" "Teams" "DID" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Organization")
                $DRMAN_PLUGINS_DIR/githubVCR/org-github-vcr.sh
            ;;
            "VCR")
                $DRMAN_PLUGINS_DIR/githubVCR/repo-github-vcr.sh               
            ;;
            "Teams")
                bash $DRMAN_PLUGINS_DIR/githubVCR/team-github-vcr.sh
            ;;
            "Quit")
                exit 0
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}