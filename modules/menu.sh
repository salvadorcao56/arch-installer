# =========================
# FILE: modules/menu.sh
# =========================
main_menu() {
    OPTION=$(whiptail --title "Arch Installer PRO" --menu "Selecciona:" 15 60 4 \
    "1" "Instalación completa" \
    "2" "Salir" 3>&1 1>&2 2>&3)

    case $OPTION in
        1) run_install ;;
        2) exit ;;
    esac
}

run_install() {
    setup_disk
    install_base_system
    configure_system
    configure_initramfs
    create_user
    install_desktop
    install_hacker_tools
    configure_snapshots
    install_bootloader
}


