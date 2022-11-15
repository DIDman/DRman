function __drm_vcr() {
    PS3="Please choose an operation: "
    vcrs=("Github" "Gitlab" "Quit")
    select opt in "${vcrs[@]}"
    do
        case $opt in
            "Github")
                export VCR='github'
                $DRMAN_PLUGINS_DIR/VCR/drman-git.sh
                ;;
            "Gitlab")
                export VCR='gitlab'
                $DRMAN_PLUGINS_DIR/VCR/drman-git.sh
                ;;
            "Quit")
                echo "We are done!"
                break
                ;;
            *) echo "invalid option $REPLY" ;;
        esac
    done
}
