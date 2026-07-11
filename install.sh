#!/usr/bin/env bash
# =============================================================
#  i3-nord-dotfiles installer for Debian (Trixie)
# =============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DST="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Toggles (utiles para pruebas):
#   SKIP_APT=1   -> no instala paquetes con apt
#   SKIP_FONT=1  -> no descarga la Nerd Font
#   SKIP_DM=1    -> no habilita LightDM
SKIP_APT="${SKIP_APT:-0}"
SKIP_FONT="${SKIP_FONT:-0}"
SKIP_DM="${SKIP_DM:-0}"

info()  { printf "\033[0;36m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[+]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

# ---- 1. Comprobar que es Debian ------------------------------
if [ "$SKIP_APT" != "1" ] && ! command -v apt >/dev/null 2>&1; then
  warn "Este script está pensado para Debian/apt. Abortando."
  warn "(Usa SKIP_APT=1 para probar sin instalar paquetes.)"
  exit 1
fi

# ---- 2. Instalar paquetes ------------------------------------
install_packages() {
  if [ "$SKIP_APT" = "1" ]; then
    warn "SKIP_APT=1 -> omitiendo instalación de paquetes."
    return
  fi
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
  if [ "$SKIP_FONT" = "1" ]; then
    warn "SKIP_FONT=1 -> omitiendo instalación de Nerd Font."
    return
  fi
  local font_dir="$HOME/.local/share/fonts"
  if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "JetBrainsMono Nerd Font"; then
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

# ---- 3b. Tema GTK Nordic (no está en repos Debian) ----------
install_gtk_theme() {
  if [ "$SKIP_APT" = "1" ]; then
    warn "SKIP_APT=1 -> omitiendo instalación del tema GTK Nordic."
    return
  fi
  if [ -d /usr/share/themes/Nordic ]; then
    ok "Tema GTK 'Nordic' ya está instalado."
    return
  fi
  info "Instalando tema GTK 'Nordic' en /usr/share/themes..."
  local tmp
  tmp="$(mktemp -d)"
  local url="https://github.com/EliverLara/Nordic/archive/refs/heads/master.tar.gz"
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$url" -o "$tmp/nordic.tar.gz" || { warn "No se pudo descargar Nordic."; rm -rf "$tmp"; return; }
  else
    wget -O "$tmp/nordic.tar.gz" "$url" || { warn "No se pudo descargar Nordic."; rm -rf "$tmp"; return; }
  fi
  tar -xzf "$tmp/nordic.tar.gz" -C "$tmp"
  sudo mkdir -p /usr/share/themes/Nordic
  sudo cp -r "$tmp"/Nordic-master/* /usr/share/themes/Nordic/
  rm -rf "$tmp"
  ok "Tema GTK 'Nordic' instalado."
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

# ---- 6. Login Nord (lightdm-gtk-greeter) ---------------------
deploy_greeter() {
  if [ "$SKIP_DM" = "1" ]; then
    warn "SKIP_DM=1 -> omitiendo tema de login (greeter)."
    return
  fi
  local src="$DOTFILES_DIR/system/lightdm-gtk-greeter.conf"
  local dst="/etc/lightdm/lightdm-gtk-greeter.conf"
  [ -f "$src" ] || { warn "No existe $src; omito greeter."; return; }

  info "Aplicando tema de login Nord (lightdm-gtk-greeter)..."
  # Copia el wallpaper a una ruta accesible por el greeter (usuario lightdm)
  if [ -f "$DOTFILES_DIR/wallpapers/nord.png" ]; then
    sudo cp "$DOTFILES_DIR/wallpapers/nord.png" /usr/share/backgrounds/nord.png
  fi
  # Backup del greeter previo
  if [ -f "$dst" ] && [ ! -f "$dst.i3nord.bak" ]; then
    sudo cp "$dst" "$dst.i3nord.bak"
    warn "Backup del greeter previo: $dst.i3nord.bak"
  fi
  sudo cp "$src" "$dst"
  ok "Login Nord aplicado."
  warn "El tema GTK 'Nordic' y cursor 'Bibata' deben estar instalados en el sistema."
  warn "  Nordic: https://github.com/EliverLara/Nordic (a /usr/share/themes)"
  warn "  Bibata: paquete 'bibata-cursor-theme' o manual (opcional)."
}

# ---- 7. Habilitar LightDM ------------------------------------
enable_lightdm() {
  if [ "$SKIP_DM" = "1" ]; then
    warn "SKIP_DM=1 -> omitiendo habilitación de LightDM."
    return
  fi
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
  install_gtk_theme
  deploy_configs
  deploy_wallpaper
  deploy_greeter
  enable_lightdm
  echo
  ok "Instalación completa."
  info "Reinicia y elige la sesión 'i3' en LightDM."
  info "Consejo: usa 'lxappearance' para aplicar tema/iconos (Nordic + Papirus)."
}

main "$@"
