# =========================
# FILE: README.md
# =========================

# 🐧 Arch Installer PRO MAX

Instalador semi-automático y modular de Arch Linux pensado para uso personal avanzado, con soporte para cifrado, BTRFS, snapshots y perfiles de seguridad.

---

## 🚀 Características

- 🔐 **Cifrado completo (LUKS)**
- 📦 **Sistema de archivos BTRFS** con subvolúmenes
- ⏱️ **Snapshots automáticos (snapper)**
- 🖥️ **Instalación de entornos gráficos**:
  - XFCE
  - KDE Plasma
  - GNOME
  - Hyprland + Waybar
  - i3
- 🎛️ **Interfaz interactiva (whiptail)**
- 🧠 **Configuración automática del sistema**:
  - Zona horaria España
  - Teclado español
  - Locale ES
- 👤 **Creación de usuario con permisos sudo**
- 🕶️ **Modo hacking opcional**:
  - nmap
  - metasploit
  - wireshark
  - burpsuite
- 📜 **Logging completo de instalación** (`install.log`)

---

## 🧱 Arquitectura

```
arch-installer/
├── install.sh
├── modules/
│   ├── disk.sh
│   ├── system.sh
│   ├── user.sh
│   ├── desktop.sh
│   ├── boot.sh
│   ├── security.sh
│   ├── snapshots.sh
│   ├── menu.sh
│   └── log.sh
└── README.md
```

---

## ⚙️ Requisitos

- ISO oficial de Arch Linux
- Conexión a Internet
- Ejecutar como root desde el live environment

---

## 🛠️ Uso

### 1. Arrancar desde ISO de Arch

### 2. Conectar a Internet

WiFi:
```
iwctl
```

### 3. Clonar repositorio

```
git clone https://github.com/TU-USUARIO/arch-installer.git
cd arch-installer
```

### 4. Ejecutar instalador

```
chmod +x install.sh
./install.sh
```

---

## 🔐 Cifrado

Si activas LUKS:

- Se cifrará todo el sistema
- Se pedirá contraseña al arrancar
- Protección completa de datos

---

## 📦 BTRFS + Snapshots

- Subvolúmenes:
  - `@` → root
  - `@home` → home

- Snapper:
  - snapshots automáticos
  - limpieza automática

---

## ⚠️ Advertencias

- ⚠️ **Prueba primero en máquina virtual**
- ⚠️ El particionado automático BORRA el disco seleccionado
- ⚠️ Hyprland puede no funcionar correctamente en VM

---

## 🧠 Roadmap

- [ ] Swapfile en BTRFS
- [ ] Soporte ZRAM
- [ ] Perfiles avanzados (dev / pentest / minimal)
- [ ] UI más avanzada (whiptail completo)
- [ ] Soporte multi-disco / RAID

---

## 🤝 Contribuciones

Este proyecto está pensado como laboratorio personal, pero puedes:

- abrir issues
- proponer mejoras
- hacer forks

---

## 📜 Licencia

MIT

---

## 💀 Autor

Salva — Proyecto personal de automatización y aprendizaje en Linux, sysadmin y ciberseguridad.

