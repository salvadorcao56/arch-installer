# =========================
# FILE: modules/menu.sh
# =========================

main_menu() {
    OPTION=$(whiptail --title "Arch Installer" --menu "Selecciona una opción:" 18 60 6 \
        "1" "Instalación completa" \
        "2" "Solo conectar WiFi" \
        "3" "Ver log de instalación" \
        "4" "Salir" 3>&1 1>&2 2>&3)

    case $OPTION in
        1) run_install ;;
        2) connect_wifi ;;
        3) cat install.log 2>/dev/null | less ;;
        4) exit ;;
    esac
}

run_install() {
    connect_wifi
    setup_disk
    install_base_system
    configure_system
    configure_initramfs
    create_user
    install_desktop
    install_dotfiles
    select_packages
    install_aur_packages
    install_hacker_tools
    configure_snapshots
    install_bootloader
    whiptail --msgbox "Instalación completada. Reinicia con 'reboot'" 10 60
}
