# =========================
# FILE: modules/wifi.sh
# =========================

connect_wifi() {
    WIFI_OPTION=$(whiptail --yesno "¿Conectar a WiFi?" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)
    [[ "$WIFI_OPTION" != "yes" ]] && return

    # detectar interfaz wifi
    IFACE=$(iwctl device list 2>/dev/null | awk '/station/ {print $1}')
    if [[ -z "$IFACE" ]]; then
        IFACE=$(iw dev 2>/dev/null | awk '/Interface/ {print $2}' | head -1)
    fi
    if [[ -z "$IFACE" ]]; then
        whiptail --msgbox "No se detectó interfaz WiFi" 8 60
        return
    fi

    iwctl station "$IFACE" scan
    sleep 2
    NETWORKS=$(iwctl station "$IFACE" get-networks 2>/dev/null | tail -n +5 | head -n -1 | sed 's/^[[:space:]]*//' | awk '{print $1}' | grep -v '^$')

    if [[ -z "$NETWORKS" ]]; then
        whiptail --msgbox "No se encontraron redes en $IFACE" 8 60
        return
    fi

    MENU_ITEMS=()
    while IFS= read -r net; do
        MENU_ITEMS+=("$net" "$net")
    done <<< "$NETWORKS"

    SSID=$(whiptail --menu "Redes WiFi disponibles ($IFACE):" 20 60 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
    [[ -z "$SSID" ]] && return

    PASSWORD=$(whiptail --inputbox "Contraseña para $SSID (visible):" 8 60 3>&1 1>&2 2>&3)
    [[ -z "$PASSWORD" ]] && return

    iwctl station "$IFACE" connect "$SSID" --passphrase "$PASSWORD"
    sleep 3

    if ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
        whiptail --msgbox "Conectado a $SSID correctamente" 8 60
    else
        whiptail --msgbox "Error al conectar a $SSID. Comprueba la contraseña." 8 60
    fi
}
