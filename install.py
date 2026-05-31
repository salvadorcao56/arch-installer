#!/usr/bin/env python3
import subprocess, os, sys, re, time
from pathlib import Path

MNT = Path('/mnt')
STATE = {'luks': False, 'fs': 'btrfs'}

def cmd(*args, check=True):
    r = subprocess.run(args, capture_output=True, text=True)
    if check and r.returncode != 0:
        print(f"ERROR: {' '.join(args)}\n{r.stderr}")
        sys.exit(1)
    return r

def chroot(*args, check=True):
    return cmd('arch-chroot', str(MNT), *args, check=check)

def whiptail(title, text, inputbox=False, yesno=False, menu=False, menu_items=None,
             checklist=False, checklist_items=None, msgbox=False, height=15, width=60):
    a = ['whiptail', '--title', title]
    if yesno: a += ['--yesno', text, str(height), str(width)]
    elif msgbox: a += ['--msgbox', text, str(height), str(width)]
    elif inputbox: a += ['--inputbox', text, str(height), str(width)]
    elif menu and menu_items:
        a += ['--menu', text, str(height), str(width), str(len(menu_items))] + [x for pair in menu_items for x in pair]
    elif checklist and checklist_items:
        a += ['--checklist', text, str(height), str(width), str(len(checklist_items))] + [x for pair in checklist_items for x in pair]
    r = subprocess.run(a + ['--output-fd', '1'], stdout=subprocess.PIPE, text=True)
    return r.returncode == 0, r.stdout.strip() if r.stdout else ''

def inp(t, d=''): return whiptail(t, t, inputbox=True)[1] or d
def yes(t): return whiptail(t, t, yesno=True)[0]
def msg(t): whiptail(t, t, msgbox=True)

def to_mib(v):
    v = v.upper()
    return int(v[:-1]) * 1024 if v.endswith('G') else int(v[:-1]) if v.endswith('M') else int(v)

def connect_wifi():
    if not yes("Conectar WiFi?"): return
    r = cmd('iwctl', 'device', 'list', check=False)
    ifaces = [l.split()[0] for l in r.stdout.splitlines() if 'station' in l]
    iface = ifaces[0] if ifaces else inp("Interfaz (ej: wlan0):", "wlan0")
    cmd('iwctl', 'station', iface, 'scan', check=False); time.sleep(2)
    cmd('iwctl', 'station', iface, 'get-networks', check=False)
    s = inp("SSID:"); p = inp("Contraseña (visible):")
    cmd('iwctl', '--passphrase', p, 'station', iface, 'connect', s, check=False); time.sleep(5)
    msg("Conectado (verifica con ping)")

def setup_disk():
    r = cmd('lsblk', '-d', '-o', 'NAME,SIZE,MODEL')
    d = r.stdout.strip().splitlines(); d = d[0].split()[0] if d else 'sda'
    disk = inp(f"Discos:\n{r.stdout}\nDisco:", d)
    dp = f"/dev/{disk}"
    if not os.path.exists(dp): msg(f"ERROR: {dp} no existe"); sys.exit(1)
    STATE['luks'] = yes("Usar LUKS?")
    STATE['fs'] = whiptail("FS", "Sistema de archivos:", menu=True,
        menu_items=[("btrfs","Btrfs"), ("ext4","Ext4")])[1] or "btrfs"
    custom = yes("Particionado manual?")
    p = 'p' if disk.startswith('nvme') or disk.startswith('mmcblk') else ''
    cmd('parted', '-s', dp, 'mklabel', 'gpt')
    cmd('parted', '-s', dp, 'mkpart', 'ESP', 'fat32', '1MiB', '513MiB')
    cmd('parted', '-s', dp, 'set', '1', 'esp', 'on')
    efi, pn, st = f"{dp}{p}1", 2, 513
    rp = hp = sp = None
    if custom:
        r2 = cmd('parted', '-s', dp, 'unit', 'MiB', 'print')
        end = int([l for l in r2.stdout.splitlines() if f'Disk {dp}' in l][0].split()[2].replace('MiB',''))
        while True:
            free, free_g = end - st, (end - st) // 1024
            rs = inp(f"ROOT (quedan {free_g}G libres)\nEj: 40G o vacio=resto:")
            if not rs:
                cmd('parted', '-s', dp, 'mkpart', 'primary', f'{st}MiB', '100%'); rp = f"{dp}{p}2"; break
            rm = to_mib(rs); free -= rm
            ss = inp(f"SWAP (quedan {free//1024}G libres)\nEj: 4G o vacio=sin swap:")
            sm = to_mib(ss) if ss else 0; free -= sm
            hs = inp(f"HOME (quedan {free//1024}G libres)\nEj: 100G o vacio=resto:")
            hm = to_mib(hs) if hs else 0
            er, es, eh = st + rm, st + rm + sm, st + rm + sm + hm
            s = f"Particiones:\nROOT: {st}-{er}MiB\n" + (f"SWAP: {er}-{es}MiB\n" if ss else "") + (f"HOME: {es}-{eh}MiB\n" if hs else f"HOME: {es}-{end}MiB\n")
            if yes(f"{s}\nContinuar? Se borra TODO"): break
        if rs:
            cmd('parted', '-s', dp, 'mkpart', 'primary', f'{st}MiB', f'{st+rm}MiB'); rp = f"{dp}{p}{pn}"; pn+=1; st+=rm
            if ss: cmd('parted', '-s', dp, 'mkpart', 'primary', 'linux-swap', f'{st}MiB', f'{st+sm}MiB'); sp = f"{dp}{p}{pn}"; pn+=1; st+=sm
            cmd('parted', '-s', dp, 'mkpart', 'primary', f'{st}MiB', '100%'); hp = f"{dp}{p}{pn}"
    else:
        cmd('parted', '-s', dp, 'mkpart', 'primary', f'{st}MiB', '100%'); rp = f"{dp}{p}2"
    cmd('mkfs.fat', '-F32', efi)
    if sp: cmd('mkswap', sp); cmd('swapon', sp); Path('/tmp/swap_part').write_text(sp)
    if STATE['luks']:
        pwd = inp("Contrasena LUKS (visible):")
        subprocess.run(['cryptsetup', 'luksFormat', '--type', 'luks1', rp], input=pwd, capture_output=True, text=True)
        subprocess.run(['cryptsetup', 'open', rp, 'cryptroot'], input=pwd, capture_output=True, text=True)
        rd = '/dev/mapper/cryptroot'
        Path('/tmp/crypt_uuid').write_text(cmd('blkid', '-s', 'UUID', '-o', 'value', rp).stdout.strip())
    else: rd = rp
    if STATE['fs'] == 'btrfs':
        cmd('mkfs.btrfs', '-f', rd); cmd('mount', rd, str(MNT))
        cmd('btrfs', 'subvolume', 'create', str(MNT/'@')); cmd('btrfs', 'subvolume', 'create', str(MNT/'@home'))
        cmd('umount', str(MNT))
        cmd('mount', '-o', 'subvol=@', rd, str(MNT)); (MNT/'home').mkdir(exist_ok=True)
        cmd('mount', '-o', 'subvol=@home', rd, str(MNT/'home'))
    else:
        cmd('mkfs.ext4', '-F', rd); cmd('mount', rd, str(MNT))
        if hp: cmd('mkfs.ext4', '-F', hp); (MNT/'home').mkdir(exist_ok=True); cmd('mount', hp, str(MNT/'home'))
    (MNT/'boot/efi').mkdir(parents=True, exist_ok=True); cmd('mount', efi, str(MNT/'boot/efi'))
    msg("Particionado completado")

def install_base():
    cmd('pacstrap', str(MNT), 'base', 'linux', 'linux-firmware', 'btrfs-progs',
        'networkmanager', 'sudo', 'git', 'vim', 'zsh', 'alacritty', 'grub', 'efibootmgr')
    (MNT/'etc/fstab').write_text(cmd('genfstab', '-U', str(MNT)).stdout)
    if Path('/tmp/swap_part').exists():
        with open(MNT/'etc/fstab', 'a') as f: f.write(f"{Path('/tmp/swap_part').read_text().strip()} none swap defaults 0 0\n")

def configure_system():
    h = inp("Hostname:", "archlinux"); z = inp("Zona horaria:", "Europe/Madrid")
    chroot('ln', '-sf', f'/usr/share/zoneinfo/{z}', '/etc/localtime'); chroot('hwclock', '--systohc')
    with open(MNT/'etc/locale.gen', 'a') as f: f.write("es_ES.UTF-8 UTF-8\n")
    chroot('locale-gen')
    (MNT/'etc/locale.conf').write_text("LANG=es_ES.UTF-8\n")
    (MNT/'etc/vconsole.conf').write_text("KEYMAP=es\n")
    (MNT/'etc/hostname').write_text(f"{h}\n")
    with open(MNT/'etc/hosts', 'w') as f:
        f.write("127.0.0.1   localhost\n::1         localhost\n"
                f"127.0.1.1   {h}.localdomain {h}\n")
    cmd('systemctl', f'--root={MNT}', 'enable', 'NetworkManager')

def configure_initramfs():
    hooks = 'base udev autodetect modconf block keyboard keymap filesystems fsck'
    if STATE['luks']: hooks = 'base udev autodetect modconf block keyboard keymap encrypt filesystems fsck'
    chroot('sed', '-i', f's/^HOOKS=.*/HOOKS=({hooks})/', '/etc/mkinitcpio.conf')
    chroot('mkinitcpio', '-P')

def create_user():
    u = inp("Nombre de usuario:"); pw = inp(f"Contrasena para {u} (visible):")
    rp = inp("Contrasena root (vacio=misma):") or pw
    Path('/tmp/username').write_text(u); (MNT/'tmp/username').write_text(u)
    chroot('useradd', '-m', '-G', 'wheel,sudo', '-s', '/bin/zsh', u)
    subprocess.run(['arch-chroot', str(MNT), 'chpasswd'], input=f"{u}:{pw}\n")
    subprocess.run(['arch-chroot', str(MNT), 'chpasswd'], input=f"root:{rp}\n")
    chroot('sed', '-i', 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) NOPASSWD: ALL/', '/etc/sudoers')
    msg(f"Usuario {u} creado")

def install_bootloader():
    if STATE['luks'] and Path('/tmp/crypt_uuid').exists():
        cu = Path('/tmp/crypt_uuid').read_text().strip()
        cfg = Path(MNT/'etc/default/grub').read_text()
        cfg = re.sub(r'^GRUB_CMDLINE_LINUX=".*"', f'GRUB_CMDLINE_LINUX="cryptdevice=UUID={cu}:cryptroot"', cfg, count=1, flags=re.MULTILINE)
        cfg = re.sub(r'^#GRUB_ENABLE_CRYPTODISK=y', 'GRUB_ENABLE_CRYPTODISK=y', cfg, count=1, flags=re.MULTILINE)
        Path(MNT/'etc/default/grub').write_text(cfg)
    chroot('grub-install', '--target=x86_64-efi', '--efi-directory=/boot/efi', '--bootloader-id=GRUB', '--removable')
    chroot('grub-mkconfig', '-o', '/boot/grub/grub.cfg')

def configure_snapshots():
    if STATE['fs'] != 'btrfs': msg("Snapper solo con btrfs, saltando"); return
    chroot('pacman', '-S', 'snapper', '--noconfirm')
    chroot('snapper', '-c', 'root', 'create-config', '/')
    chroot('snapper', '-c', 'root', 'set-config', 'TIMELINE_CREATE=yes', 'TIMELINE_CLEANUP=yes')
    cmd('systemctl', f'--root={MNT}', 'enable', 'snapper-timeline.timer')
    cmd('systemctl', f'--root={MNT}', 'enable', 'snapper-cleanup.timer')
    chroot('snapper', '-c', 'root', 'create', '-d', 'Sistema recien instalado')

def install_yay():
    if not yes("Instalar yay?"): return
    msg("Compilando yay desde AUR... varios minutos.")
    s = '''set -e
pacman -S --needed base-devel git --noconfirm
useradd -m tempbuild 2>/dev/null || true
echo "tempbuild ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
su - tempbuild -c "cd /tmp && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm"
sed -i '/^tempbuild/d' /etc/sudoers; chmod 0440 /etc/sudoers; userdel -r tempbuild 2>/dev/null || true'''
    subprocess.run(['arch-chroot', str(MNT), 'bash', '-c', s])

def install_desktop():
    c = whiptail("WM", "Selecciona WM:", menu=True, menu_items=[
        ("i3","i3wm - Recomendado"), ("hyprland","Hyprland - Potente"),
        ("xfce","XFCE - Ligero"), ("kde","KDE Plasma"), ("none","No instalar")])[1] or "none"
    if c == "none": return
    if c == "i3":
        chroot('pacman', '-S', 'i3-wm', 'i3status', 'i3lock', 'dmenu', 'picom', 'feh', 'alacritty', 'i3blocks', '--noconfirm')
        chroot('pacman', '-S', 'lightdm', 'lightdm-gtk-greeter', '--noconfirm')
        cmd('systemctl', f'--root={MNT}', 'enable', 'lightdm')
        chroot('systemctl', 'set-default', 'graphical.target')
    elif c == "hyprland":
        chroot('pacman', '-S', 'hyprland', 'waybar', 'alacritty', 'wofi', 'dunst', '--noconfirm')
    elif c == "xfce":
        chroot('pacman', '-S', 'xfce4', 'xfce4-goodies', 'lightdm', 'lightdm-gtk-greeter', '--noconfirm')
        cmd('systemctl', f'--root={MNT}', 'enable', 'lightdm')
        chroot('systemctl', 'set-default', 'graphical.target')
    elif c == "kde":
        chroot('pacman', '-S', 'plasma', 'sddm', '--noconfirm')
        cmd('systemctl', f'--root={MNT}', 'enable', 'sddm')
        chroot('systemctl', 'set-default', 'graphical.target')
    Path('/tmp/wm_choice').write_text(c)

def install_dotfiles():
    if not yes("Copiar configs/ al home?"): return
    u = Path('/tmp/username').read_text().strip()
    cmd('cp', '-r', '/root/arch-installer/configs/.', str(MNT/f'home/{u}/'))
    for p in Path(MNT/f'home/{u}').iterdir():
        chroot('chown', '-R', f'{u}:{u}', f'/home/{u}/{p.name}')

def select_packages():
    ok, v = whiptail("Paquetes", "Selecciona (ESPACIO):", checklist=True, height=20, width=70, checklist_items=[
        ("firefox","Navegador","OFF"),("chromium","Navegador","OFF"),("thunderbird","Correo","OFF"),
        ("vlc","Multimedia","OFF"),("gimp","Imagenes","OFF"),("libreoffice-fresh","Ofimatica","OFF"),
        ("code","VS Code","OFF"),("neovim","Editor","OFF"),("tmux","Terminal","OFF"),
        ("htop","Monitor","OFF"),("fastfetch","Info","OFF"),("base-devel","Compilacion","OFF"),
        ("docker","Contenedores","OFF"),("flatpak","Flatpak","OFF"),("steam","Juegos","OFF"),
        ("keepassxc","Passwords","OFF"),("obs-studio","Streaming","OFF"),("virt-manager","VMs","OFF")])
    if ok and v:
        for pkg in v.replace('"','').split(): chroot('pacman','-S',pkg,'--noconfirm')

def install_aur_packages():
    if subprocess.run(['arch-chroot',str(MNT),'which','yay'], capture_output=True).returncode != 0: return
    ok, v = whiptail("AUR", "Selecciona (ESPACIO):", checklist=True, height=20, width=70, checklist_items=[
        ("google-chrome","Chrome","OFF"),("visual-studio-code-bin","VS Code","OFF"),
        ("discord","Discord","OFF"),("spotify","Spotify","OFF"),
        ("anydesk-bin","AnyDesk","OFF"),("burpsuite","Burp","OFF"),
        ("metasploit","Metasploit","OFF"),("obsidian","Obsidian","OFF")])
    if ok and v:
        u = Path('/tmp/username').read_text().strip()
        subprocess.run(['arch-chroot',str(MNT),'sudo','-u',u,'yay','-S',*v.replace('"','').split(),'--noconfirm'])

def hacker():
    if yes("Herramientas de hacking?"):
        chroot('pacman','-S','nmap','wireshark-qt','--noconfirm')

def main():
    os.environ.setdefault('TERM','xterm-256color')
    steps = [
        ("WiFi", connect_wifi), ("Particionado", setup_disk), ("Base", install_base),
        ("Configurar sistema", configure_system), ("Initramfs", configure_initramfs),
        ("Usuario", create_user), ("Bootloader", install_bootloader),
        ("Snapshots", configure_snapshots), ("Yay", install_yay),
        ("Escritorio", install_desktop), ("Dotfiles", install_dotfiles),
        ("Paquetes", select_packages), ("AUR", install_aur_packages), ("Hacking", hacker),
    ]
    for i,(n,f) in enumerate(steps,1):
        print(f"\n--- Paso {i}/{len(steps)}: {n} ---")
        try: f()
        except Exception as e: print(f"ERROR en paso {i} ({n}): {e}"); sys.exit(1)
    msg("Instalacion completada. Apaga, desconecta ISO y reinicia.")

if __name__ == '__main__': main()
