# =========================
# FILE: modules/user.sh
# =========================
create_user() {
    USERNAME=$(whiptail --inputbox "Usuario" 10 60 3>&1 1>&2 2>&3)
    PASSWORD=$(whiptail --passwordbox "Password" 10 60 3>&1 1>&2 2>&3)

arch-chroot /mnt /bin/bash <<EOF
useradd -m -G wheel -s /bin/zsh $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
EOF
}


