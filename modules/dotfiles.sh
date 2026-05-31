# =========================
# FILE: modules/dotfiles.sh
# =========================

install_dotfiles() {
    local USER=$(cat /tmp/username)
    local HOME_DIR="/mnt/home/$USER"

    local SCRIPT_DIR
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    local DOTFILES_DIR="$SCRIPT_DIR/configs"

    if [ ! -d "$DOTFILES_DIR/i3" ] && [ ! -d "$DOTFILES_DIR/zsh" ]; then
        return
    fi

    USE_DOTFILES=$(whiptail --yesno "¿Copiar configuraciones (dotfiles) al sistema nuevo?\n\nIncluye: i3, i3blocks, zsh, nvim, vim, ranger, ghostty, thunar, yazi" 12 65 3>&1 1>&2 2>&3 && echo yes || echo no)
    [[ "$USE_DOTFILES" != "yes" ]] && return

    mkdir -p "$HOME_DIR/.config"

    # i3
    if [ -d "$DOTFILES_DIR/i3" ]; then
        mkdir -p "$HOME_DIR/.config/i3"
        cp -r "$DOTFILES_DIR/i3/"* "$HOME_DIR/.config/i3/"
    fi

    # i3blocks
    if [ -d "$DOTFILES_DIR/i3blocks" ]; then
        mkdir -p "$HOME_DIR/.config/i3blocks"
        cp -r "$DOTFILES_DIR/i3blocks/"* "$HOME_DIR/.config/i3blocks/"
    fi

    # zsh
    if [ -d "$DOTFILES_DIR/zsh" ]; then
        cp "$DOTFILES_DIR/zsh/zshrc" "$HOME_DIR/.zshrc" 2>/dev/null
        cp "$DOTFILES_DIR/zsh/zshrc-personal" "$HOME_DIR/.zshrc-personal" 2>/dev/null
        cp "$DOTFILES_DIR/zsh/alias.zsh" "$HOME_DIR/.alias.zsh" 2>/dev/null
        cp "$DOTFILES_DIR/zsh/comandos.zsh" "$HOME_DIR/.comandos.zsh" 2>/dev/null
        cp "$DOTFILES_DIR/zsh/p10k.zsh" "$HOME_DIR/.p10k.zsh" 2>/dev/null
        mkdir -p "$HOME_DIR/.zsh"
        cp -r "$DOTFILES_DIR/zsh/plugins" "$HOME_DIR/.zsh/plugins" 2>/dev/null
        cp -r "$DOTFILES_DIR/zsh/zsh-vi-mode" "$HOME_DIR/.zsh/zsh-vi-mode" 2>/dev/null
        cp "$DOTFILES_DIR/zsh/web-search.plugin.zsh" "$HOME_DIR/.zsh/" 2>/dev/null
    fi

    # nvim
    if [ -d "$DOTFILES_DIR/nvim" ]; then
        mkdir -p "$HOME_DIR/.config/nvim"
        cp -r "$DOTFILES_DIR/nvim/"* "$HOME_DIR/.config/nvim/"
    fi

    # vim
    if [ -d "$DOTFILES_DIR/vim" ]; then
        cp -r "$DOTFILES_DIR/vim" "$HOME_DIR/.vim"
    fi

    # ranger
    if [ -d "$DOTFILES_DIR/ranger" ]; then
        mkdir -p "$HOME_DIR/.config/ranger"
        cp -r "$DOTFILES_DIR/ranger/"* "$HOME_DIR/.config/ranger/"
    fi

    # ghostty
    if [ -d "$DOTFILES_DIR/ghostty" ]; then
        mkdir -p "$HOME_DIR/.config/ghostty"
        cp -r "$DOTFILES_DIR/ghostty/"* "$HOME_DIR/.config/ghostty/"
    fi

    # thunar
    if [ -d "$DOTFILES_DIR/thunar" ]; then
        mkdir -p "$HOME_DIR/.config/Thunar"
        cp -r "$DOTFILES_DIR/thunar/"* "$HOME_DIR/.config/Thunar/"
    fi

    # yazi
    if [ -d "$DOTFILES_DIR/yazi" ]; then
        mkdir -p "$HOME_DIR/.config/yazi"
        cp -r "$DOTFILES_DIR/yazi/"* "$HOME_DIR/.config/yazi/"
    fi

    # nanorc
    [ -f "$DOTFILES_DIR/nanorc" ] && cp "$DOTFILES_DIR/nanorc" "$HOME_DIR/.nanorc"

    # ideavimrc
    [ -f "$DOTFILES_DIR/ideavimrc" ] && cp "$DOTFILES_DIR/ideavimrc" "$HOME_DIR/.ideavimrc"

    # gitignore
    [ -f "$DOTFILES_DIR/gitignore" ] && cp "$DOTFILES_DIR/gitignore" "$HOME_DIR/.gitignore"

    arch-chroot /mnt chown -R $USER:$USER "/home/$USER"

    whiptail --msgbox "Dotfiles copiados correctamente" 8 60
}
