# =========================
# FILE: modules/packages.sh
# =========================

select_packages() {
    PACKAGES=$(whiptail --checklist "Selecciona paquetes a instalar (ESPACIO para marcar):" 20 70 12 \
        "firefox"          "Navegador web" OFF \
        "chromium"         "Navegador web" OFF \
        "thunderbird"      "Cliente de correo" OFF \
        "vlc"              "Reproductor multimedia" OFF \
        "gimp"             "Editor de imágenes" OFF \
        "libreoffice"      "Suite ofimática" OFF \
        "code"             "Visual Studio Code" OFF \
        "neovim"           "Editor de texto avanzado" OFF \
        "tmux"             "Terminal multiplexer" OFF \
        "htop"             "Monitor de procesos" OFF \
        "neofetch"         "Info del sistema" OFF \
        "base-devel"       "Herramientas de compilación" OFF \
        "docker"           "Contenedores" OFF \
        "flatpak"          "Gestor de paquetes Flatpak" OFF \
        "steam"            "Plataforma de juegos" OFF \
        "keepassxc"        "Gestor de contraseñas" OFF \
        "obs-studio"       "Grabación/streaming" OFF \
        "virt-manager"     "Máquinas virtuales" OFF \
        3>&1 1>&2 2>&3)

    if [[ -n "$PACKAGES" ]]; then
        SELECTED=$(echo "$PACKAGES" | sed 's/"//g')
        arch-chroot /mnt pacman -S $SELECTED --noconfirm
    fi
}

install_yay() {
    local USER=$(cat /tmp/username)
arch-chroot /mnt /bin/bash <<EOF
pacman -S --needed base-devel git --noconfirm
useradd -m tempbuild 2>/dev/null || true
echo "tempbuild ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
su - tempbuild -c "cd /tmp && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm"
sed -i '/^tempbuild/d' /etc/sudoers
userdel -r tempbuild 2>/dev/null || true
EOF
}

install_aur_packages() {
    YAY_OPTION=$(whiptail --yesno "¿Instalar paquetes desde AUR (yay)?" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)
    [[ "$YAY_OPTION" != "yes" ]] && return

    install_yay

    AUR_PACKAGES=$(whiptail --checklist "Selecciona paquetes AUR (yay):" 20 70 8 \
        "google-chrome"     "Google Chrome" OFF \
        "visual-studio-code-bin" "VS Code (AUR)" OFF \
        "discord"           "Discord" OFF \
        "anydesk-bin"       "AnyDesk" OFF \
        3>&1 1>&2 2>&3)

    if [[ -n "$AUR_PACKAGES" ]]; then
        AUR_SELECTED=$(echo "$AUR_PACKAGES" | sed 's/"//g')
        local USER=$(cat /tmp/username)
        arch-chroot /mnt sudo -u "$USER" yay -S $AUR_SELECTED --noconfirm
    fi
}
