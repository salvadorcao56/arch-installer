#!/bin/bash

FILE="$HOME/dotfiles/i3/config.d"

# Sacamos binds + limpiamos
CHOICE=$(grep -h '^bindsym' "$FILE"/*.conf 2>/dev/null | \
sed 's/bindsym //' | \
awk '{
    key=$1
    $1=""
    sub(/^ /, "")
    print key " | " $0
}' | \
rofi -dmenu -i -p "i3 shortcuts")

# Si no selecciona nada, salir
[ -z "$CHOICE" ] && exit

# Separar tecla y comando
CMD=$(echo "$CHOICE" | cut -d'|' -f2- | sed 's/^ *//')

# Ejecutar
eval "$CMD"
