# =========================
# FILE: modules/desktop.sh
# =========================
install_desktop() {
    DESKTOP=$(whiptail --menu "Entorno gráfico" 15 60 5 \
    "xfce" "XFCE" \
    "kde" "KDE Plasma" \
    "gnome" "GNOME" \
    "hypr" "Hyprland" \
    "i3" "i3" 3>&1 1>&2 2>&3)

    case $DESKTOP in
        xfce)
            arch-chroot /mnt pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
            arch-chroot /mnt systemctl enable lightdm ;;
        kde)
            arch-chroot /mnt pacman -S plasma kde-applications sddm --noconfirm
            arch-chroot /mnt systemctl enable sddm ;;
        gnome)
            arch-chroot /mnt pacman -S gnome gdm --noconfirm
            arch-chroot /mnt systemctl enable gdm ;;
        hypr)
            arch-chroot /mnt pacman -S hyprland waybar alacritty --noconfirm ;;
        i3)
            arch-chroot /mnt pacman -S i3-wm i3status dmenu alacritty --noconfirm ;;
    esac
}


