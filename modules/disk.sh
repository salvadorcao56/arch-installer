# =========================
# FILE: modules/disk.sh
# =========================
setup_disk() {
    USE_LUKS=$(whiptail --yesno "¿Usar cifrado LUKS?" 10 60 3>&1 1>&2 2>&3 && echo yes || echo no)

    lsblk
    DISK=$(whiptail --inputbox "Disco (ej: sda)" 10 60 3>&1 1>&2 2>&3)

    parted /dev/$DISK --script mklabel gpt

    parted /dev/$DISK --script mkpart ESP fat32 1MiB 513MiB
    parted /dev/$DISK --script set 1 esp on

    parted /dev/$DISK --script mkpart primary 513MiB 100%

    EFI="/dev/${DISK}1"
    ROOT_PART="/dev/${DISK}2"

    mkfs.fat -F32 $EFI

    if [[ "$USE_LUKS" == "yes" ]]; then
        cryptsetup luksFormat $ROOT_PART
        cryptsetup open $ROOT_PART cryptroot
        ROOT_DEV="/dev/mapper/cryptroot"
        CRYPT_UUID=$(blkid -s UUID -o value $ROOT_PART)
        echo "$CRYPT_UUID" > /tmp/crypt_uuid
    else
        ROOT_DEV=$ROOT_PART
    fi

    mkfs.btrfs $ROOT_DEV
    mount $ROOT_DEV /mnt

    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home

    umount /mnt

    mount -o subvol=@ $ROOT_DEV /mnt
    mkdir -p /mnt/home
    mount -o subvol=@home $ROOT_DEV /mnt/home

    mkdir -p /mnt/boot/efi
    mount $EFI /mnt/boot/efi
}


