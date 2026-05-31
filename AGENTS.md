# Arch Installer - Contexto del proyecto

## Estado actual
Proyecto funcional, listo para probar en MV. Todos los módulos implementados.
Ultima prueba: pendiente (2026-05-31).

## Que hace
Instalador semi-automatico de Arch Linux desde la ISO. Menu interactivo con whiptail que guia todo el proceso.

## Flujo de instalacion (menu.sh -> run_install)
1. connect_wifi       -> escanea redes, elige SSID, contraseña visible
2. setup_disk         -> elige disco, LUKS, btrfs/ext4, particionado manual con tamaños
3. install_base_system -> pacstrap base + genfstab
4. configure_system   -> hostname, zona horaria, locale, teclado, NetworkManager
5. configure_initramfs -> hooks de mkinitcpio (con encrypt si LUKS)
6. create_user        -> usuario+password visible, grupo wheel+sudo, password root
7. install_desktop    -> i3 / hyprland / xfce / kde / none
8. install_dotfiles   -> copia configs/ (i3, i3blocks, zsh, nvim, vim, ranger, ghostty, thunar, yazi, nanorc, ideavimrc)
9. select_packages    -> checklist de paquetes oficiales
10. install_aur_packages -> compila yay, checklist de AUR
11. install_hacker_tools -> nmap, wireshark-qt
12. configure_snapshots  -> snapper, snapshot inicial "Sistema recien instalado"
13. install_bootloader   -> GRUB EFI, con soporte LUKS

## Modulos
- log.sh        -> logging a install.log
- menu.sh       -> menu principal + run_install
- wifi.sh       -> iwctl, deteccion dinamica de interfaz, timeout ping
- disk.sh       -> parted, to_mib(), LUKS, btrfs/ext4, subvolumes @ y @home
- system.sh     -> pacstrap, config locale/hostname/timezone, mkinitcpio
- user.sh       -> useradd, chpasswd, sudoers
- desktop.sh    -> instala WM, enable DM, chown configs
- packages.sh   -> checklist oficiales, yay desde tempbuild, checklist AUR
- dotfiles.sh   -> copia configs/ al home del usuario, chown
- boot.sh       -> grub-install + grub-mkconfig, cryptdevice si LUKS
- security.sh   -> nmap + wireshark-qt
- snapshots.sh  -> snapper create-config, timers, snapshot inicial

## Configs incluidas (configs/)
i3, i3blocks, zsh, nvim, vim, ranger, ghostty, thunar, yazi, nanorc, ideavimrc
Excluidas por seguridad: SSH (claves), neomutt (credenciales email), Code (caché)

## Estructura
arch-installer/
├── install.sh           # entry point, sourcea todos los modulos
├── create-test-vm.sh    # crea MV en VirtualBox
├── modules/             # modulos bash
├── configs/             # dotfiles
├── AGENTS.md            # este archivo
├── README.md
└── .gitignore

## Lo que pregunta el instalador
- WiFi? -> escanea -> SSID -> contraseña visible
- Disco? -> LUKS? -> btrfs/ext4? -> particion manual? -> tamaños root/swap/home
- Hostname? -> zona horaria?
- Usuario? -> contraseña visible -> password root visible
- WM: i3 (modesto) / hyprland (potente) / xfce / kde / none
- Dotfiles? (copia configs)
- Paquetes oficiales (checklist)
- Yay + AUR (checklist)
- Hacking tools?
- Snapper y GRUB

## Script de prueba
- create-test-vm.sh crea MV en QEMU+KVM (ya no VirtualBox)
- Dependencias: qemu-system-x86_64 + edk2-ovmf
- OVMF en /usr/share/edk2/x64/ (OVMF_CODE.4m.fd / OVMF_VARS.4m.fd)
- Usa UEFI, disco qcow2, red NAT (slirp), display GTK

## Pendientes / Roadmap
- [X] Migrar de VirtualBox a QEMU
- [ ] Probar en MV
- [ ] Perfiles predefinidos (minimal, dev, gaming)
- [ ] Swapfile en BTRFS
- [ ] Instalacion desde archiso personalizado
- [ ] Soporte multi-disco

## Notas tecnicas
- Usa parted (no sgdisk) porque sgdisk no esta en la ISO de Arch
- yay se compila con usuario temporal tempbuild (makepkg no puede ser root)
- Las contraseñas son visibles (--inputbox), no ocultas
- ES_LANG: es_ES.UTF-8, KEYMAP=es
- Uso de set -e en install.sh
