# =========================
# FILE: modules/snapshots.sh
# =========================
configure_snapshots() {
arch-chroot /mnt /bin/bash <<EOF
pacman -S snapper --noconfirm
snapper -c root create-config /
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
EOF
}
