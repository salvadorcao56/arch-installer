# =========================
# FILE: modules/security.sh
# =========================

install_hacker_tools() {
    HACK=$(whiptail --yesno "¿Instalar herramientas de red/hacking?\n(nmap, wireshark)" 10 60 3>&1 1>&2 2>&3 && echo yes || echo no)

    if [[ "$HACK" == "yes" ]]; then
        arch-chroot /mnt pacman -S nmap wireshark-qt --noconfirm
    fi
}
