# =========================
# FILE: modules/system.sh
# =========================

install_base_system() {
    pacstrap /mnt base linux linux-firmware btrfs-progs networkmanager sudo git vim zsh alacritty
    genfstab -U /mnt >> /mnt/etc/fstab

    if [ -f /tmp/swap_part ]; then
        SWAP_PART=$(cat /tmp/swap_part)
        echo "$SWAP_PART none swap defaults 0 0" >> /mnt/etc/fstab
    fi
}

configure_system() {
    HOSTNAME=$(whiptail --inputbox "Nombre del host:" 8 60 "archlinux" 3>&1 1>&2 2>&3)
    [[ -z "$HOSTNAME" ]] && HOSTNAME="archlinux"

    ZONE=$(whiptail --inputbox "Zona horaria (ej: Europe/Madrid):" 8 60 "Europe/Madrid" 3>&1 1>&2 2>&3)
    [[ -z "$ZONE" ]] && ZONE="Europe/Madrid"

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/$ZONE /etc/localtime
hwclock --systohc

echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf
echo "$HOSTNAME" > /etc/hostname

cat >> /etc/hosts <<HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

systemctl enable NetworkManager 2>/dev/null || true
EOF
}

configure_initramfs() {
    if [ -f /tmp/crypt_uuid ]; then
arch-chroot /mnt /bin/bash <<EOF
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P 2>/dev/null || true
EOF
    else
arch-chroot /mnt /bin/bash <<EOF
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block keyboard keymap filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P 2>/dev/null || true
EOF
    fi
}
