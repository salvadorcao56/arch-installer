# =========================
# FILE: modules/snapshots.sh
# =========================

configure_snapshots() {
    if [[ "$FS_CHOICE" != "btrfs" ]]; then
        whiptail --msgbox "Snapper solo funciona con btrfs. Saltando configuración de snapshots." 8 60
        return
    fi

arch-chroot /mnt /bin/bash <<EOF
pacman -S snapper --noconfirm

snapper -c root create-config /

if [[ -d /.snapshots ]]; then
    mv /.snapshots /.snapshots.bak
    mkdir /.snapshots
    btrfs subvolume create /.snapshots
    mv /.snapshots.bak/* /.snapshots/ 2>/dev/null || true
    rm -rf /.snapshots.bak
fi

snapper -c root set-config TIMELINE_CREATE=yes
snapper -c root set-config TIMELINE_CLEANUP=yes
snapper -c root set-config TIMELINE_MIN_AGE=1800
snapper -c root set-config TIMELINE_LIMIT_HOURLY=5
snapper -c root set-config TIMELINE_LIMIT_DAILY=7
snapper -c root set-config TIMELINE_LIMIT_WEEKLY=0
snapper -c root set-config TIMELINE_LIMIT_MONTHLY=0
snapper -c root set-config TIMELINE_LIMIT_YEARLY=0

    systemctl enable --force snapper-timeline.timer 2>/dev/null || true
    systemctl enable --force snapper-cleanup.timer 2>/dev/null || true

echo "snapshot inicial" | snapper -c root create -d "Sistema recien instalado" -c timeline
EOF
}
