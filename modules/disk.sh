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
    DISKS=$(lsblk -d -o NAME,SIZE,MODEL | grep -v "^loop" | grep -v "^NAME" 2>/dev/null)
    local DEFAULT_DISK=$(echo "$DISKS" | head -1 | awk '{print $1}')
    DISK=$(whiptail --inputbox "Discos disponibles:

$DISKS

Escribe el nombre del disco donde instalar (ej: sda):" 18 70 "$DEFAULT_DISK" 3>&1 1>&2 2>&3)
    [[ -z "$DISK" ]] && exit 1

    DISK_PATH="/dev/$DISK"
    PART_PREFIX=""
    [[ "$DISK" == nvme* || "$DISK" == mmcblk* ]] && PART_PREFIX="p"

    if ! parted -s "$DISK_PATH" unit MiB print >/dev/null 2>&1; then
        whiptail --msgbox "ERROR: No se puede acceder a $DISK_PATH" 8 60
        exit 1
    fi

    USE_LUKS=$(whiptail --yesno "¿Usar cifrado LUKS?" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)
    FS_CHOICE=$(whiptail --menu "Sistema de archivos:" 10 60 2 \
        "btrfs" "Btrfs (recomendado)" \
        "ext4"  "Ext4" 3>&1 1>&2 2>&3)
    CUSTOM_PART=$(whiptail --yesno "¿Particionado manual? (NO = todo el disco para /)" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)

    DISK_END=$(parted -s "$DISK_PATH" unit MiB print 2>/dev/null | grep "Disk $DISK_PATH" | awk '{print $3}' | sed 's/MiB//')
    if [[ -z "$DISK_END" ]]; then
        whiptail --msgbox "ERROR: No se pudo determinar el tamaño del disco" 8 60
        exit 1
    fi

    parted -s "$DISK_PATH" mklabel gpt
    parted -s "$DISK_PATH" mkpart ESP fat32 1MiB 513MiB
    parted -s "$DISK_PATH" set 1 esp on
    EFI="${DISK_PATH}${PART_PREFIX}1"

    local START=513
    local PART_NUM=2

    if [[ "$CUSTOM_PART" == "yes" ]]; then
        local FREE=$((DISK_END - START))
        local FREE_G=$((FREE / 1024))

        ROOT_SIZE=$(whiptail --inputbox "Tamaño ROOT — Quedan ${FREE_G}G libres
Ej: 40G, o vacío = resto del disco:" 11 65 3>&1 1>&2 2>&3)

        if [[ -n "$ROOT_SIZE" ]]; then
            local R_MIB=$(to_mib "$ROOT_SIZE")
            local FREE=$((FREE - R_MIB))
            local FREE_G=$((FREE / 1024))

            SWAP_SIZE=$(whiptail --inputbox "Tamaño SWAP — Quedan ${FREE_G}G libres
Ej: 4G, o vacío = sin swap:" 11 65 3>&1 1>&2 2>&3)

            local S_MIB=0
            if [[ -n "$SWAP_SIZE" ]]; then
                S_MIB=$(to_mib "$SWAP_SIZE")
                FREE=$((FREE - S_MIB))
                FREE_G=$((FREE / 1024))
            fi

            HOME_SIZE=$(whiptail --inputbox "Tamaño HOME — Quedan ${FREE_G}G libres
Ej: 100G, o vacío = resto del disco:" 11 65 3>&1 1>&2 2>&3)

            local H_MIB=0
            if [[ -n "$HOME_SIZE" ]]; then
                H_MIB=$(to_mib "$HOME_SIZE")
                FREE=$((FREE - H_MIB))
            fi

            local END=$((START + R_MIB))

            SUMMARY="Particiones a crear en $DISK_PATH:\n\n"
            SUMMARY+="  ESP:   1MiB - 513MiB\n"
            SUMMARY+="  ROOT:  513MiB - ${END}MiB (${ROOT_SIZE}B)\n"
            if [[ -n "$SWAP_SIZE" ]]; then
                SUMMARY+="  SWAP:  ${END}MiB - $((END + S_MIB))MiB (${SWAP_SIZE}B)\n"
            fi
            if [[ -n "$HOME_SIZE" ]]; then
                SUMMARY+="  HOME:  $((END + S_MIB))MiB - $((END + S_MIB + H_MIB))MiB (${HOME_SIZE}B)\n"
            fi
            SUMMARY+="\n¿Continuar? Se borrará TODO el contenido del disco"

            whiptail --yesno "$SUMMARY" 18 70 3>&1 1>&2 2>&3 || exit 1

            parted -s "$DISK_PATH" mkpart primary ${START}MiB ${END}MiB
            ROOT_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
            START=$END
            ((PART_NUM++))

            if [[ -n "$SWAP_SIZE" ]]; then
                local END=$((START + S_MIB))
                parted -s "$DISK_PATH" mkpart primary linux-swap ${START}MiB ${END}MiB
                SWAP_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
                START=$END
                ((PART_NUM++))
            fi

            if [[ -n "$HOME_SIZE" ]]; then
                local END=$((START + H_MIB))
                parted -s "$DISK_PATH" mkpart primary ${START}MiB ${END}MiB
                HOME_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
                START=$END
                ((PART_NUM++))
            fi

            if [[ $FREE -gt 100 ]]; then
                whiptail --yesno "Quedan $((FREE / 1024))G sin particionar. ¿Asignarlos al final del disco?" 10 60
                if [[ $? -eq 0 ]]; then
                    parted -s "$DISK_PATH" mkpart primary ${START}MiB 100%
                    HOME_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
                    ((PART_NUM++))
                fi
            fi
        else
            parted -s "$DISK_PATH" mkpart primary ${START}MiB 100%
            ROOT_PART="${DISK_PATH}${PART_PREFIX}${PART_NUM}"
            HOME_SIZE=""
            SWAP_SIZE=""
        fi
    else
        parted -s "$DISK_PATH" mkpart primary ${START}MiB 100%
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
