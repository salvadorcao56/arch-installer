# =========================
# FILE: modules/dotfiles.sh
# =========================

install_dotfiles() {
    local USER
    USER=$(cat /tmp/username 2>/dev/null || echo "")
    if [[ -z "$USER" ]]; then
        whiptail --msgbox "ERROR: No se encuentra /tmp/username. ¿Se creó el usuario?" 8 60
        exit 1
    fi
    local HOME_DIR="/mnt/home/$USER"
    local DOTFILES_DST="$HOME_DIR/dotfiles"

    local SCRIPT_DIR
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    local DOTFILES_SRC="$SCRIPT_DIR/configs"

    if [ ! -d "$DOTFILES_SRC/i3" ] && [ ! -d "$DOTFILES_SRC/zsh" ]; then
        return
    fi

    USE_DOTFILES=$(whiptail --yesno "Copiar configuraciones (dotfiles) al sistema nuevo?

Incluye: i3, i3blocks, zsh, nvim, vim, ranger, ghostty, thunar, yazi" 12 65 3>&1 1>&2 2>&3 && echo yes || echo no)
    [[ "$USE_DOTFILES" != "yes" ]] && return

    whiptail --msgbox "Se copiarán las configuraciones a ~/dotfiles/
y se crearán enlaces simbólicos." 10 60

    mkdir -p "$DOTFILES_DST" 2>/dev/null || true

    copy_to_dotfiles() {
        local src="$1"
        if [ -e "$src" ]; then
            cp -r "$src" "$DOTFILES_DST/" 2>/dev/null || true
        fi
    }

    symlink_dir() {
        local target="$1" link="$2"
        mkdir -p "$(dirname "$link")" 2>/dev/null || true
        rm -rf "$link" 2>/dev/null || true
        ln -sf "$target" "$link" 2>/dev/null || true
    }

    symlink_file() {
        local target="$1" link="$2"
        mkdir -p "$(dirname "$link")" 2>/dev/null || true
        rm -f "$link" 2>/dev/null || true
        ln -sf "$target" "$link" 2>/dev/null || true
    }

    for item in "$DOTFILES_SRC"/*; do
        [ -e "$item" ] && copy_to_dotfiles "$item"
    done
    for item in "$DOTFILES_SRC"/.[!.]*; do
        [ -e "$item" ] && copy_to_dotfiles "$item"
    done

    symlink_dir "$DOTFILES_DST/i3" "$HOME_DIR/.config/i3"
    symlink_dir "$DOTFILES_DST/i3blocks" "$HOME_DIR/.config/i3blocks"
    symlink_dir "$DOTFILES_DST/ghostty" "$HOME_DIR/.config/ghostty"
    symlink_dir "$DOTFILES_DST/nvim" "$HOME_DIR/.config/nvim"
    symlink_dir "$DOTFILES_DST/ranger" "$HOME_DIR/.config/ranger"
    symlink_dir "$DOTFILES_DST/yazi" "$HOME_DIR/.config/yazi"
    symlink_dir "$DOTFILES_DST/thunar" "$HOME_DIR/.config/Thunar"
    symlink_dir "$DOTFILES_DST/vim" "$HOME_DIR/.vim"

    symlink_file "$DOTFILES_DST/zsh/zshrc-personal" "$HOME_DIR/.zshrc"
    symlink_file "$DOTFILES_DST/nanorc" "$HOME_DIR/.nanorc"
    symlink_file "$DOTFILES_DST/ideavimrc" "$HOME_DIR/.ideavimrc"

    arch-chroot /mnt chown -R "$USER:$USER" "$DOTFILES_DST" 2>/dev/null || true

    whiptail --msgbox "Dotfiles copiados a ~/dotfiles/ con enlaces simbólicos" 8 60
}
