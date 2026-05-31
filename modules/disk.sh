# =========================
# FILE: modules/disk.sh
# =========================

setup_disk() {
    lsblk -d -o NAME,SIZE,MODEL | grep -v "^loop"
    DISK=$(whiptail --inputbox "Disco a instalar (ej: sda, nvme0n1):" 10 60 3>&1 1>&2 2>&3)
    [[ -z "$DISK" ]] && exit 1

    DISK_PATH="/dev/$DISK"
    PART_PREFIX=""
    [[ "$DISK" == nvme* ]] && PART_PREFIX="p"

    USE_LUKS=$(whiptail --yesno "¿Usar cifrado LUKS?" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)

    FS_CHOICE=$(whiptail --menu "Sistema de archivos:" 10 60 2 \
        "btrfs" "Btrfs (recomendado)" \
        "ext4"  "Ext4" 3>&1 1>&2 2>&3)

    CUSTOM_PART=$(whiptail --yesno "¿Particionado manual? (NO = auto: todo a root)" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)

    parted "$DISK_PATH" --script mklabel gpt
    parted "$DISK_PATH" --script mkpart ESP fat32 1MiB 513MiB
    parted "$DISK_PATH" --script set 1 esp on
    EFI="${DISK_PATH}${PART_PREFIX}1"

    if [[ "$CUSTOM_PART" == "yes" ]]; then
        ROOT_SIZE=$(whiptail --inputbox "Tamaño partición ROOT (ej: 40G, o vacío para usar resto):" 10 60 3>&1 1>&2 2>&3)
        SWAP_SIZE=$(whiptail --inputbox "Tamaño SWAP (ej: 4G, o vacío para no crear swap):" 10 60 3>&1 1>&2 2>&3)
        HOME_SIZE=$(whiptail --inputbox "Tamaño partición HOME (ej: 100G, o vacío para usar resto):" 10 60 3>&1 1>&2 2>&3)

        local next_start="513MiB"

        if [[ -n "$ROOT_SIZE" ]]; then
            parted "$DISK_PATH" --script mkpart primary "$next_start" "$ROOT_SIZE"
            ROOT_PART="${DISK_PATH}${PART_PREFIX}2"
            next_start="$ROOT_SIZE"
        else
            parted "$DISK_PATH" --script mkpart primary "$next_start" 100%
            ROOT_PART="${DISK_PATH}${PART_PREFIX}2"
        fi

        if [[ -n "$SWAP_SIZE" ]]; then
            parted "$DISK_PATH" --script mkpart primary linux-swap "$next_start" "$SWAP_SIZE"
            SWAP_PART="${DISK_PATH}${PART_PREFIX}3"
            next_start="$SWAP_SIZE"
        fi

        if [[ -n "$HOME_SIZE" ]]; then
            if [[ -z "$ROOT_SIZE" ]]; then
                HOME_SIZE=""
                whiptail --msgbox "No hay espacio para /home si root usa todo el disco" 8 60
            else
                parted "$DISK_PATH" --script mkpart primary "$next_start" "$HOME_SIZE"
                HOME_PART="${DISK_PATH}${PART_PREFIX}4"
            fi
        fi
    else
        parted "$DISK_PATH" --script mkpart primary 513MiB 100%
        ROOT_PART="${DISK_PATH}${PART_PREFIX}2"
    fi

    mkfs.fat -F32 "$EFI"

    if [[ -n "$SWAP_PART" ]]; then
        mkswap "$SWAP_PART"
        swapon "$SWAP_PART"
        echo "$SWAP_PART" > /tmp/swap_part
    fi

    if [[ "$USE_LUKS" == "yes" ]]; then
        LUKS_PASSWORD=$(whiptail --inputbox "Contraseña para LUKS (visible):" 8 60 3>&1 1>&2 2>&3)
        echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat "$ROOT_PART" -
        echo -n "$LUKS_PASSWORD" | cryptsetup open "$ROOT_PART" cryptroot -
        ROOT_DEV="/dev/mapper/cryptroot"
        CRYPT_UUID=$(blkid -s UUID -o value "$ROOT_PART")
        echo "$CRYPT_UUID" > /tmp/crypt_uuid
    else
        ROOT_DEV="$ROOT_PART"
    fi

    if [[ "$FS_CHOICE" == "btrfs" ]]; then
        mkfs.btrfs -f "$ROOT_DEV"
        mount "$ROOT_DEV" /mnt
        btrfs subvolume create /mnt/@
        btrfs subvolume create /mnt/@home
        umount /mnt
        mount -o subvol=@ "$ROOT_DEV" /mnt
        mkdir -p /mnt/home
        mount -o subvol=@home "$ROOT_DEV" /mnt/home
    else
        mkfs.ext4 -F "$ROOT_DEV"
        mount "$ROOT_DEV" /mnt
        if [[ -n "$HOME_PART" ]]; then
            mkfs.ext4 -F "$HOME_PART"
            mkdir -p /mnt/home
            mount "$HOME_PART" /mnt/home
        fi
    fi

    mkdir -p /mnt/boot
    mount "$EFI" /mnt/boot

    whiptail --msgbox "Particionado completado correctamente" 8 60
}
