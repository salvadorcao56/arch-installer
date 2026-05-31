# =========================
# FILE: modules/desktop.sh
# =========================

install_desktop() {
    WM_CHOICE=$(whiptail --menu "Selecciona Window Manager / Entorno:" 15 65 5 \
        "i3"       "i3wm - Recomendado para equipos modestos" \
        "hyprland" "Hyprland - Para equipos más potentes" \
        "xfce"     "XFCE - Entorno ligero" \
        "kde"      "KDE Plasma - Entorno completo" \
        "none"     "No instalar interfaz gráfica" 3>&1 1>&2 2>&3)

    case $WM_CHOICE in
        i3)
            arch-chroot /mnt pacman -S i3-wm i3status i3lock dmenu picom feh alacritty i3blocks --noconfirm
            arch-chroot /mnt pacman -S lightdm lightdm-gtk-greeter --noconfirm
            arch-chroot /mnt systemctl enable lightdm
            arch-chroot /mnt systemctl set-default graphical.target
            ;;
        hyprland)
            arch-chroot /mnt pacman -S hyprland waybar alacritty wofi dunst --noconfirm
            arch-chroot /mnt systemctl enable NetworkManager
            mkdir -p /mnt/home/$(cat /tmp/username)/.config/hypr
            cat > /mnt/home/$(cat /tmp/username)/.config/hypr/hyprland.conf <<'HYPR'
monitor=,preferred,auto,1
exec-once=waybar & dunst
bind=SUPER,RETURN,exec,alacritty
bind=SUPER,D,exec,wofi --show drun
bind=SUPER,Q,killactive,
HYPR
            arch-chroot /mnt chown -R $(cat /tmp/username):$(cat /tmp/username) /home/$(cat /tmp/username)
            ;;
        xfce)
            arch-chroot /mnt pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
            arch-chroot /mnt systemctl enable lightdm
            arch-chroot /mnt systemctl set-default graphical.target
            ;;
        kde)
            arch-chroot /mnt pacman -S plasma sddm --noconfirm
            arch-chroot /mnt systemctl enable sddm
            arch-chroot /mnt systemctl set-default graphical.target
            ;;
        none)
            return ;;
    esac

    echo "$WM_CHOICE" > /tmp/wm_choice
}
