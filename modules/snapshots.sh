# =========================
# FILE: modules/snapshots.sh
# =========================

configure_snapshots() {
arch-chroot /mnt /bin/bash <<EOF
pacman -S snapper --noconfirm

snapper -c root create-config /

snapper -c root set-config TIMELINE_CREATE=yes
snapper -c root set-config TIMELINE_CLEANUP=yes
snapper -c root set-config TIMELINE_MIN_AGE=1800
snapper -c root set-config TIMELINE_LIMIT_HOURLY=5
snapper -c root set-config TIMELINE_LIMIT_DAILY=7
snapper -c root set-config TIMELINE_LIMIT_WEEKLY=0
snapper -c root set-config TIMELINE_LIMIT_MONTHLY=0
snapper -c root set-config TIMELINE_LIMIT_YEARLY=0

systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer

echo "snapshot inicial" | snapper -c root create -d "Sistema recien instalado" -c timeline
EOF
}
