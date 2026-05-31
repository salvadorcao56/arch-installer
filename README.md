# =========================
# FILE: README.md
# =========================

# Arch Installer

Instalador semi-automático y modular de Arch Linux. Te conecta a WiFi, particiona el disco a tu gusto, elige entre i3 (equipos modestos) o Hyprland (equipos potentes), y seleccionas los paquetes que quieres instalar con checklist.

---

## Caracteristicas

- **WiFi interactivo**: Escanea redes, eliges una, introduces la contraseña visible
- **Particionado manual**: Eliges disco, tamaño de root, swap, home y sistema de archivos (btrfs/ext4)
- **Cifrado LUKS** con contraseña visible
- **Window Managers**:
  - i3 (equipos modestos)
  - Hyprland (equipos potentes)
  - XFCE / KDE
- **Checklist de paquetes**: Marca con espacio lo que quieras instalar, tanto de repos como AUR con yay
- **Contraseñas visibles** con inputbox (nada de password oculto)
- **Hostname y zona horaria** configurables
- **Snapshots automáticos** con snapper
- **Herramientas de hacking** opcionales (nmap, metasploit, wireshark, burpsuite)
- **Logging** completo en install.log

---

## Como se usa

### 1. Arrancas desde la ISO de Arch

### 2. Clonas esto

```bash
git clone https://github.com/salvadorcao56/arch-installer.git
cd arch-installer
```

### 3. Ejecutas

```bash
chmod +x install.sh
./install.sh
```

### 4. El instalador te guia

1. Te pregunta si conectar a WiFi -> escanea redes -> eliges -> pones contraseña
2. Te pide el disco -> si quieres LUKS -> filesystem -> particionado manual con tamaños
3. Instala el sistema base
4. Configura hostname, zona horaria, locale, teclado
5. Crea usuario y contraseñas (visibles)
6. Elige WM: i3 (modesto) o Hyprland (potente)
7. Checklist de paquetes para marcar
8. Instalacion de yay + paquetes AUR
9. Herramientas de hacking
10. Snapshots con snapper
11. Bootloader GRUB

---

## A tener en cuenta

- El particionado **BORRA** el disco seleccionado
- Prueba en maquina virtual primero
- i3 funciona mejor en VMs que Hyprland

---

## Estructura

```
arch-installer/
├── install.sh
├── modules/
│   ├── disk.sh          Particionado interactivo
│   ├── system.sh        Instalacion base + config sistema
│   ├── user.sh          Creacion de usuario
│   ├── desktop.sh       WM selection (i3, hyprland, xfce, kde)
│   ├── wifi.sh          Escaneo y conexion WiFi
│   ├── packages.sh      Checklist paquetes + AUR
│   ├── boot.sh          GRUB + LUKS
│   ├── security.sh      Herramientas hacking
│   ├── snapshots.sh     Snapper
│   ├── menu.sh          Menu principal
│   └── log.sh           Logging
└── README.md
```

---

## Roadmap

- [ ] Perfiles predefinidos (minimal, dev, gaming)
- [ ] Swapfile en BTRFS
- [ ] Instalacion desde archiso personalizado
- [ ] Configuracion de dotfiles automatica

---

MIT - Salva

