function __drm_vcr() {
    PS3="Please choose an operation: "
    vcrs=("Github" "Gitlab" "Quit")
    select opt in "${vcrs[@]}"
    do
        case $opt in
            "Github")
                export VCR='github'
                source ~/.drman/src/drman-git.sh
                __drm_gitVCR
                ;;
            "Gitlab")
                export VCR='gitlab'
                source ~/.drman/src/drman-git.sh
                __drm_gitVCR
                ;;
            "Quit")
                echo "We are done!"
                break
                ;;
            *) echo "invalid option $REPLY" ;;
        esac
    done
}
