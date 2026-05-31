# =========================
# FILE: modules/wifi.sh
# =========================

connect_wifi() {
    WIFI_OPTION=$(whiptail --yesno "¿Conectar a WiFi?" 8 60 3>&1 1>&2 2>&3 && echo yes || echo no)
    [[ "$WIFI_OPTION" != "yes" ]] && return

    iwctl station wlan0 scan
    sleep 2
    NETWORKS=$(iwctl station wlan0 get-networks 2>/dev/null | tail -n +5 | head -n -1 | sed 's/^[[:space:]]*//' | awk '{print $1}' | grep -v '^$')

    if [[ -z "$NETWORKS" ]]; then
        whiptail --msgbox "No se encontraron redes o no hay interfaz wlan0" 8 60
        return
    fi

    MENU_ITEMS=()
    while IFS= read -r net; do
        MENU_ITEMS+=("$net" "$net")
    done <<< "$NETWORKS"

    SSID=$(whiptail --menu "Redes WiFi disponibles:" 20 60 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
    [[ -z "$SSID" ]] && return

    PASSWORD=$(whiptail --inputbox "Contraseña para $SSID (visible):" 8 60 3>&1 1>&2 2>&3)
    [[ -z "$PASSWORD" ]] && return

    iwctl station wlan0 connect "$SSID" --passphrase "$PASSWORD"
    sleep 3

    if ping -c 1 8.8.8.8 &>/dev/null; then
        whiptail --msgbox "Conectado a $SSID correctamente" 8 60
    else
        whiptail --msgbox "Error al conectar a $SSID. Comprueba la contraseña." 8 60
    fi
}
