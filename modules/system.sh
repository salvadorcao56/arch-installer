# =========================
# FILE: modules/system.sh
# =========================
install_base_system() {
    pacstrap /mnt base linux linux-firmware btrfs-progs networkmanager sudo git vim zsh alacritty
    genfstab -U /mnt >> /mnt/etc/fstab
}

configure_system() {
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=es_ES.UTF-8" > /etc/locale.conf

echo "KEYMAP=es" > /etc/vconsole.conf

echo "archlinux" > /etc/hostname
systemctl enable NetworkManager
EOF
}

configure_initramfs() {
arch-chroot /mnt /bin/bash <<EOF
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P
EOF
}


