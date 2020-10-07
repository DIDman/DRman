# main menu

function __drm_githubVCR() {
    PS3='Please choose your target VCR: '
    options=("Create" "Delete" "Other")
    select opt in "${options[@]}"
    do
        case $opt in
            "Create")
                echo "Lets Create Github VCR"
                sh ./create-github-vcr.sh
                ;;
            "Delete")
                echo "You opeted to delete Gitlab VCR"
                sh ./delete-github-vcr.sh           
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