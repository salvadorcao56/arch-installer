# =========================
# FILE: modules/disk.sh
# =========================

to_mib() {
    local val=$1
    val=$(echo "$val" | tr '[:lower:]' '[:upper:]')
    if [[ $val == *G ]]; then
        echo $((${val%G} * 1024))
    elif [[ $val == *M ]]; then
        echo ${val%M}
    else
        echo $((val))
    fi
}

setup_disk() {
    lsblk -d -o NAME,SIZE,MODEL | grep -v "^loop"
    DISK=$(whiptail --inputbox "Disco a instalar (ej: sda, nvme0n1):" 10 60 3>&1 1>&2 2>&3)
    [[ -z "$DISK" ]] && exit 1

    DISK_PATH="/dev/$DISK"
    PART_PREFIX=""
    [[ "$DISK" == nvme* || "$DISK" == mmcblk* ]] && PART_PREFIX="p"

    USE_LUKS=$(whiptail --yesno "¿Usar cifrado LUKS?" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)
    FS_CHOICE=$(whiptail --menu "Sistema de archivos:" 10 60 2 \
        "btrfs" "Btrfs (recomendado)" \
        "ext4"  "Ext4" 3>&1 1>&2 2>&3)
    CUSTOM_PART=$(whiptail --yesno "¿Particionado manual? (NO = todo el disco para /)" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)

    DISK_END=$(parted "$DISK_PATH" unit MiB print 2>/dev/null | awk '/^[0-9]/ && /^Disk/ {print $3}' | sed 's/MiB//')
    if [[ -z "$DISK_END" ]]; then
        DISK_END=$(parted "$DISK_PATH" unit MiB print 2>/dev/null | grep "Disk $DISK_PATH" | awk '{print $3}' | sed 's/MiB//')
    fi

    parted "$DISK_PATH" --script mklabel gpt
    parted "$DISK_PATH" --script mkpart ESP fat32 1MiB 513MiB
    parted "$DISK_PATH" --script set 1 esp on
    EFI="${DISK_PATH}${PART_PREFIX}1"

    local START=513
    local PART_NUM=2

    if [[ "$CUSTOM_PART" == "yes" ]]; then
        ROOT_SIZE=$(whiptail --inputbox "Tamaño partición ROOT (ej: 40G, o vacío = resto del disco):" 10 60 3>&1 1>&2 2>&3)
        SWAP_SIZE=$(whiptail --inputbox "Tamaño SWAP (ej: 4G, o vacío = sin swap):" 10 60 3>&1 1>&2 2>&3)
        HOME_SIZE=$(whiptail --inputbox "Tamaño HOME (ej: 100G, o vacío = resto del disco):" 10 60 3>&1 1>&2 2>&3)

        if [[ -n "$ROOT_SIZE" ]]; then
            local R_MIB=$(to_mib "$ROOT_SIZE")
            local END=$((START + R_MIB))
            parted "$DISK_PATH" --script mkpart primary ${START}MiB ${END}MiB
            ROOT_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
            START=$END
            ((PART_NUM++))
        else
            parted "$DISK_PATH" --script mkpart primary ${START}MiB 100%
            ROOT_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
            ((PART_NUM++))
            HOME_SIZE=""
            SWAP_SIZE=""
        fi

        if [[ -n "$SWAP_SIZE" && -n "$ROOT_SIZE" ]]; then
            local S_MIB=$(to_mib "$SWAP_SIZE")
            local END=$((START + S_MIB))
            parted "$DISK_PATH" --script mkpart primary linux-swap ${START}MiB ${END}MiB
            SWAP_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
            START=$END
            ((PART_NUM++))
        fi

        if [[ -n "$HOME_SIZE" && -n "$ROOT_SIZE" ]]; then
            local H_MIB=$(to_mib "$HOME_SIZE")
            local END=$((START + H_MIB))
            parted "$DISK_PATH" --script mkpart primary ${START}MiB ${END}MiB
            HOME_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
            START=$END
            ((PART_NUM++))
        fi
    else
        parted "$DISK_PATH" --script mkpart primary ${START}MiB 100%
        ROOT_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
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

    mkdir -p /mnt/boot/efi
    mount "$EFI" /mnt/boot/efi

    whiptail --msgbox "Particionado completado" 8 60
}
