# main menu

function __drm_githubVCR() {
    PS3='Please choose an operation: '
    options=("Create" "Delete" "Other")
    select opt in "${options[@]}"
    do
        case $opt in
            "Create")
                echo "Lets Create Github VCR"
                read -p "Organization Name: " ORGNAME
                read -p "Repository Name: " REPONAME
                sh $DRMAN_DIR/helper/create-github-vcr.sh -o $ORGNAME -r $REPONAME
                ;;
            "Other")
                echo "To be filled"        
                ;;
            "Quit")
                exit
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}