#!/usr/bin/env bash
# =============================================================
#  i3-cyberpunk-dotfiles installer for Debian (Trixie)
# =============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DST="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

SKIP_APT="${SKIP_APT:-0}"
SKIP_FONT="${SKIP_FONT:-0}"
SKIP_DM="${SKIP_DM:-0}"

info()  { printf "\033[0;36m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[+]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

# ---- 1. Check Debian -----------------------------------------
if [ "$SKIP_APT" != "1" ] && ! command -v apt >/dev/null 2>&1; then
  warn "This script is for Debian/apt. Aborting."
  warn "(Use SKIP_APT=1 to test without installing.)"
  exit 1
fi

# ---- 2. Install packages -------------------------------------
install_packages() {
  if [ "$SKIP_APT" = "1" ]; then
    warn "SKIP_APT=1 -> skipping package installation."
    return
  fi
  info "Updating apt indexes..."
  sudo apt update

  info "Installing packages from packages.txt..."
  mapfile -t ALL_PKGS < <(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages.txt")
  PKGS=()
  for p in "${ALL_PKGS[@]}"; do
    if apt-cache policy "$p" 2>/dev/null | grep -q "Candidate: (none)"; then
      warn "Package '$p' not available -> skipped."
    else
      PKGS+=("$p")
    fi
  done
  sudo apt install -y "${PKGS[@]}"
  ok "Packages installed."
}

# ---- 3. Nerd Fonts -------------------------------------------
install_nerd_font() {
  if [ "$SKIP_FONT" = "1" ]; then
    warn "SKIP_FONT=1 -> skipping Nerd Font installation."
    return
  fi
  local font_dir="$HOME/.local/share/fonts"
  if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    ok "JetBrainsMono Nerd Font already installed."
    return
  fi
  info "Installing JetBrainsMono Nerd Font..."
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
  ok "Nerd Font installed."
}

# ---- 3b. GTK theme (dark, for Cyberpunk) ---------------------
install_gtk_theme() {
  if [ "$SKIP_APT" = "1" ]; then
    warn "SKIP_APT=1 -> skipping GTK theme installation."
    return
  fi
  info "Installing Adwaita-dark GTK theme (available by default)..."
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
  ok "GTK theme set to Adwaita-dark + Papirus-Dark."
  info "For a more cyberpunk GTK look, use lxappearance to choose a dark theme."
}

# ---- 4. Deploy configs ---------------------------------------
deploy_configs() {
  info "Deploying configs to $CONFIG_DST..."
  mkdir -p "$CONFIG_DST"
  for dir in "$CONFIG_SRC"/*/; do
    name="$(basename "$dir")"
    if [ -e "$CONFIG_DST/$name" ]; then
      mkdir -p "$BACKUP_DIR"
      warn "Backing up $name -> $BACKUP_DIR/"
      mv "$CONFIG_DST/$name" "$BACKUP_DIR/"
    fi
    rm -rf "$CONFIG_DST/$name"
    cp -r "$dir" "$CONFIG_DST/$name"
    n_bad="$(find "$CONFIG_DST/$name" -type f -size 0 2>/dev/null | wc -l)"
    if [ "$n_bad" -gt 0 ]; then
      warn "WARNING: $n_bad empty file(s) in ~/.config/$name after copy."
    fi
    ok "Installed ~/.config/$name"
  done
  chmod +x "$CONFIG_DST/polybar/launch.sh" 2>/dev/null || true
}

# ---- 5. Wallpaper --------------------------------------------
deploy_wallpaper() {
  local wp_dir="$HOME/Pictures/wallpapers"
  mkdir -p "$wp_dir"
  if [ -f "$DOTFILES_DIR/wallpapers/cyberpunk.png" ]; then
    cp "$DOTFILES_DIR/wallpapers/cyberpunk.png" "$wp_dir/cyberpunk.png"
    ok "Wallpaper copied to $wp_dir/cyberpunk.png"
  else
    warn "No wallpaper found at wallpapers/cyberpunk.png."
    warn "Place one there or edit 'feh --bg-fill' in ~/.config/i3/config."
    warn "Search: https://wallhaven.cc/search?q=cyberpunk"
  fi
}

# ---- 6. Login (lightdm-gtk-greeter) --------------------------
deploy_greeter() {
  if [ "$SKIP_DM" = "1" ]; then
    warn "SKIP_DM=1 -> skipping login greeter."
    return
  fi
  local src="$DOTFILES_DIR/system/lightdm-gtk-greeter.conf"
  local dst="/etc/lightdm/lightdm-gtk-greeter.conf"
  [ -f "$src" ] || { warn "$src not found; skipping greeter."; return; }

  info "Applying Cyberpunk greeter (lightdm-gtk-greeter)..."
  if [ -f "$DOTFILES_DIR/wallpapers/cyberpunk.png" ]; then
    sudo mkdir -p /usr/share/backgrounds
    sudo cp "$DOTFILES_DIR/wallpapers/cyberpunk.png" /usr/share/backgrounds/cyberpunk.png
    sudo chmod 644 /usr/share/backgrounds/cyberpunk.png
  fi
  if [ -f "$dst" ] && [ ! -f "$dst.i3cyberpunk.bak" ]; then
    sudo cp "$dst" "$dst.i3cyberpunk.bak"
    warn "Backup of previous greeter: $dst.i3cyberpunk.bak"
  fi
  sudo cp "$src" "$dst"
  ok "Cyberpunk greeter applied."
}

# ---- 7. Enable LightDM ---------------------------------------
enable_lightdm() {
  if [ "$SKIP_DM" = "1" ]; then
    warn "SKIP_DM=1 -> skipping LightDM enable."
    return
  fi
  if command -v systemctl >/dev/null 2>&1; then
    info "Enabling LightDM..."
    sudo systemctl enable lightdm || warn "Could not enable lightdm."
    ok "LightDM enabled (use after reboot)."
  fi
}

main() {
  info "== i3-cyberpunk-dotfiles installer =="
  install_packages
  install_nerd_font
  install_gtk_theme
  deploy_configs
  deploy_wallpaper
  deploy_greeter
  enable_lightdm
  echo
  ok "Installation complete."
  info "Reboot and select 'i3' session in LightDM."
  info "Use lxappearance to set Papirus-Dark icons + a dark GTK theme."
}

main "$@"
