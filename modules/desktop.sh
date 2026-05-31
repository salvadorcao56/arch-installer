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
            arch-chroot /mnt pacman -S i3-wm i3status i3lock dmenu picom feh alacritty --noconfirm
            arch-chroot /mnt pacman -S lightdm lightdm-gtk-greeter --noconfirm
            arch-chroot /mnt systemctl enable lightdm
            local USER=$(cat /tmp/username)
            mkdir -p /mnt/home/$USER/.config/i3
            cat > /mnt/home/$USER/.config/i3/config <<'I3CONF'
set $mod Mod4
font pango:monospace 10
bindsym $mod+Return exec alacritty
bindsym $mod+d exec dmenu_run
bindsym $mod+Shift+q kill
bindsym $mod+1 workspace 1
bindsym $mod+Shift+1 move container to workspace 1
exec_always picom -f
I3CONF
            arch-chroot /mnt chown -R $USER:$USER /home/$USER
            ;;
        hyprland)
            arch-chroot /mnt pacman -S hyprland waybar alacritty wofi dunst --noconfirm
            local USER=$(cat /tmp/username)
            mkdir -p /mnt/home/$USER/.config/hypr
            cat > /mnt/home/$USER/.config/hypr/hyprland.conf <<'HYPR'
monitor=,preferred,auto,1
exec-once=waybar & dunst
bind=SUPER,RETURN,exec,alacritty
bind=SUPER,D,exec,wofi --show drun
bind=SUPER,Q,killactive,
HYPR
            arch-chroot /mnt chown -R $USER:$USER /home/$USER
            ;;
        xfce)
            arch-chroot /mnt pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
            arch-chroot /mnt systemctl enable lightdm ;;
        kde)
            arch-chroot /mnt pacman -S plasma sddm --noconfirm
            arch-chroot /mnt systemctl enable sddm ;;
        none)
            return ;;
    esac
}
