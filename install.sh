#!/usr/bin/env bash
# =============================================================
#  i3-nord-dotfiles installer for Debian (Trixie)
# =============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DST="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

info()  { printf "\033[0;36m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[+]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

# ---- 1. Comprobar que es Debian ------------------------------
if ! command -v apt >/dev/null 2>&1; then
  warn "Este script está pensado para Debian/apt. Abortando."
  exit 1
fi

# ---- 2. Instalar paquetes ------------------------------------
install_packages() {
  info "Actualizando índices de apt..."
  sudo apt update

  info "Instalando paquetes desde packages.txt..."
  # Ignora comentarios y líneas vacías
  mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages.txt")
  sudo apt install -y "${PKGS[@]}"
  ok "Paquetes instalados."
}

# ---- 3. Nerd Fonts (paso manual automatizado) ----------------
install_nerd_font() {
  local font_dir="$HOME/.local/share/fonts"
  if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    ok "JetBrainsMono Nerd Font ya está instalada."
    return
  fi
  info "Instalando JetBrainsMono Nerd Font..."
  mkdir -p "$font_dir"
  local tmp
  tmp="$(mktemp -d)"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$url" -o "$tmp/JetBrainsMono.zip"
  else
    wget -O "$tmp/JetBrainsMono.zip" "$url"
  fi
  unzip -o "$tmp/JetBrainsMono.zip" -d "$font_dir/JetBrainsMono" >/dev/null
  rm -rf "$tmp"
  fc-cache -f >/dev/null
  ok "Nerd Font instalada."
}

# ---- 4. Copiar configuraciones (con backup) ------------------
deploy_configs() {
  info "Desplegando configuraciones a $CONFIG_DST..."
  mkdir -p "$CONFIG_DST"
  for dir in "$CONFIG_SRC"/*/; do
    name="$(basename "$dir")"
    if [ -e "$CONFIG_DST/$name" ]; then
      mkdir -p "$BACKUP_DIR"
      warn "Respaldo de $name -> $BACKUP_DIR/"
      mv "$CONFIG_DST/$name" "$BACKUP_DIR/"
    fi
    cp -r "$dir" "$CONFIG_DST/$name"
    ok "Instalado ~/.config/$name"
  done
  chmod +x "$CONFIG_DST/polybar/launch.sh" 2>/dev/null || true
}

# ---- 5. Wallpaper --------------------------------------------
deploy_wallpaper() {
  local wp_dir="$HOME/Pictures/wallpapers"
  mkdir -p "$wp_dir"
  if [ -f "$DOTFILES_DIR/wallpapers/nord.png" ]; then
    cp "$DOTFILES_DIR/wallpapers/nord.png" "$wp_dir/nord.png"
    ok "Wallpaper copiado a $wp_dir/nord.png"
  else
    warn "No hay wallpaper en wallpapers/nord.png."
    warn "Coloca uno ahí o edita la línea 'feh --bg-fill' en ~/.config/i3/config."
  fi
}

# ---- 6. Habilitar LightDM ------------------------------------
enable_lightdm() {
  if command -v systemctl >/dev/null 2>&1; then
    info "Habilitando LightDM..."
    sudo systemctl enable lightdm || warn "No se pudo habilitar lightdm."
    ok "LightDM habilitado (se usará al reiniciar)."
  fi
}

main() {
  info "== i3-nord-dotfiles installer =="
  install_packages
  install_nerd_font
  deploy_configs
  deploy_wallpaper
  enable_lightdm
  echo
  ok "Instalación completa."
  info "Reinicia y elige la sesión 'i3' en LightDM."
  info "Consejo: usa 'lxappearance' para aplicar tema/iconos (Nordic + Papirus)."
}

main "$@"
