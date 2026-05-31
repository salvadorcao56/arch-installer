# =========================
# FILE: modules/user.sh
# =========================

create_user() {
    USERNAME=$(whiptail --inputbox "Nombre de usuario:" 8 60 3>&1 1>&2 2>&3)
    [[ -z "$USERNAME" ]] && exit 1

    PASSWORD=$(whiptail --inputbox "Contraseña para $USERNAME (visible):" 8 60 3>&1 1>&2 2>&3)
    [[ -z "$PASSWORD" ]] && exit 1

    ROOT_PASSWORD=$(whiptail --inputbox "Contraseña para root (visible):" 8 60 3>&1 1>&2 2>&3)
    [[ -z "$ROOT_PASSWORD" ]] && ROOT_PASSWORD="$PASSWORD"

    echo "$USERNAME" > /tmp/username

arch-chroot /mnt /bin/bash <<EOF
useradd -m -G wheel,sudo -s /bin/zsh $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$ROOT_PASSWORD" | chpasswd
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
EOF

    whiptail --msgbox "Usuario $USERNAME creado correctamente" 8 60
}
