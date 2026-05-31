#!/bin/bash
# Crea MV en QEMU para probar el instalador
set -e

NAME="arch-installer-test"
RAM="2048"
CPUS="2"
DISK_SIZE="25600"
DISK_PATH="$HOME/VM/$NAME/disk.qcow2"
ISO_PATH="$HOME/isos/archlinux-2026.05.01-x86_64.iso"
ISO_URL="https://mirror.rackspace.com/archlinux/iso/2026.05.01/archlinux-2026.05.01-x86_64.iso"

OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS="/usr/share/edk2/x64/OVMF_VARS.4m.fd"

echo "[1/5] Verificando dependencias..."
for cmd in qemu-system-x86_64 qemu-img; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd no instalado. Ejecuta: sudo pacman -S qemu-full edk2-ovmf"
        exit 1
    fi
done
if [ ! -f "$OVMF_CODE" ]; then
    echo "ERROR: OVMF no encontrado. Ejecuta: sudo pacman -S edk2-ovmf"
    exit 1
fi
echo "  OK"

echo "[2/5] Descargando ISO si no existe..."
mkdir -p "$(dirname "$ISO_PATH")"
if [ ! -f "$ISO_PATH" ]; then
    curl -L -o "$ISO_PATH" "$ISO_URL"
else
    echo "  ISO ya existe: $ISO_PATH"
fi

echo "[3/5] Creando disco de ${DISK_SIZE}MB ($((DISK_SIZE/1024))GB)..."
mkdir -p "$HOME/VM/$NAME"
qemu-img create -f qcow2 "$DISK_PATH" "${DISK_SIZE}M"

echo "[4/5] Preparando variables UEFI..."
VARS_PATH="/tmp/${NAME}_OVMF_VARS.fd"
cp "$OVMF_VARS" "$VARS_PATH"

echo "[5/5] Arrancando QEMU..."
echo ""
echo "========================================"
echo " MV lista: $NAME"
echo " RAM: ${RAM}MB | CPU: ${CPUS} | Disco: $((DISK_SIZE/1024))GB"
echo " ISO: $(basename "$ISO_PATH")"
echo "========================================"
echo ""
echo "Dentro de la MV (Arch ISO) - al arrancar:"
echo "  # loadkeys es           # teclado español"
echo "  # setfont ter-132n      # fuente más grande"
echo ""
echo "Luego, para probar el instalador:"
echo "  # pacman -Sy git"
echo "  # git clone https://github.com/salvadorcao56/arch-installer.git"
echo "  # cd arch-installer"
echo "  # chmod +x install.sh"
echo "  # ./install.sh"
echo ""
echo ""

qemu-system-x86_64 \
    -enable-kvm \
    -machine q35 \
    -cpu host \
    -smp "$CPUS" \
    -m "$RAM" \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$VARS_PATH" \
    -drive file="$DISK_PATH",format=qcow2,if=virtio \
    -drive file="$ISO_PATH",format=raw,media=cdrom \
    -netdev user,id=net0 \
    -device virtio-net,netdev=net0 \
    -display gtk,zoom-to-fit=on \
    -k es \
    -device qemu-xhci
