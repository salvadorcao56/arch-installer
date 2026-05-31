#!/bin/bash
# =========================
# Crea MV en VirtualBox para probar el instalador
# =========================

set -e

NAME="arch-installer-test"
RAM="2048"
CPUS="2"
DISK_SIZE="25600"
DISK_PATH="$HOME/VirtualBox VMs/$NAME/disk.vdi"
ISO_PATH="$HOME/isos/archlinux-2026.05.01-x86_64.iso"
ISO_URL="https://mirror.rackspace.com/archlinux/iso/2026.05.01/archlinux-2026.05.01-x86_64.iso"

echo "[1/5] Descargando ISO si no existe..."
if [ ! -f "$ISO_PATH" ]; then
    curl -L -o "$ISO_PATH" "$ISO_URL"
else
    echo "  ISO ya existe: $ISO_PATH"
fi

echo "[2/5] Creando MV..."
VBoxManage createvm --name "$NAME" --ostype ArchLinux_64 --register 2>/dev/null || true
VBoxManage modifyvm "$NAME" --memory "$RAM" --cpus "$CPUS" --firmware efi64 --graphicscontroller vmsvga
VBoxManage modifyvm "$NAME" --nic1 nat

echo "[3/5] Creando disco de ${DISK_SIZE}MB ($((DISK_SIZE/1024))GB)..."
mkdir -p "$HOME/VirtualBox VMs/$NAME"
VBoxManage createmedium disk --filename "$DISK_PATH" --size "$DISK_SIZE" --format VDI 2>/dev/null || true

echo "[4/5] Configurando almacenamiento..."
VBoxManage storagectl "$NAME" --name "SATA" --add sata --controller IntelAhci 2>/dev/null || true
VBoxManage storageattach "$NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$DISK_PATH" 2>/dev/null || true

VBoxManage storagectl "$NAME" --name "IDE" --add ide 2>/dev/null || true
VBoxManage storageattach "$NAME" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH" 2>/dev/null || true

echo "[5/5] Hecho!"
echo ""
echo "========================================"
echo " MV lista: $NAME"
echo " RAM: ${RAM}MB | CPU: ${CPUS} | Disco: $((DISK_SIZE/1024))GB"
echo " ISO: $(basename $ISO_PATH)"
echo "========================================"
echo ""
echo "Para arrancar:"
echo "  VBoxManage startvm \"$NAME\""
echo ""
echo "Dentro de la MV (Arch ISO):"
echo "  # pacman -Sy git"
echo "  # git clone https://github.com/salvadorcao56/arch-installer.git"
echo "  # cd arch-installer"
echo "  # ./install.sh"
echo ""
