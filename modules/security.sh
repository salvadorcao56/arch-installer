# =========================
# FILE: modules/security.sh
# =========================
install_hacker_tools() {
    HACK=$(whiptail --yesno "¿Instalar herramientas hacking?" 10 60 3>&1 1>&2 2>&3 && echo yes || echo no)

    if [[ "$HACK" == "yes" ]]; then
        arch-chroot /mnt pacman -S nmap metasploit wireshark-qt burpsuite --noconfirm
    fi
}
