# =========================
# FILE: modules/boot.sh
# =========================
install_bootloader() {
    arch-chroot /mnt pacman -S grub efibootmgr --noconfirm

    if [ -f /tmp/crypt_uuid ]; then
        CRYPT_UUID=$(cat /tmp/crypt_uuid)

arch-chroot /mnt /bin/bash <<EOF
sed -i 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=UUID=$CRYPT_UUID:cryptroot"/' /etc/default/grub
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
EOF
    fi

    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable || true
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg || true
}
