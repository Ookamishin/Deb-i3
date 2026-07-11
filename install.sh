#!/usr/bin/env bash
# =============================================================
#  i3-cyberpunk-dotfiles — multi-distro installer
#  Detects: Debian/apt | Arch/pacman
# =============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DST="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

SKIP_PKG="${SKIP_PKG:-0}"
SKIP_FONT="${SKIP_FONT:-0}"
SKIP_DM="${SKIP_DM:-0}"

info()  { printf "\033[0;36m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[+]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

# ---- Distro detection -----------------------------------------
detect_distro() {
  if command -v apt >/dev/null 2>&1; then
    DISTRO="debian"
    PKG_MGR="apt"
    PKG_FILE="packages.txt"
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update"
    CHECK_PKG="apt-cache policy"
    CHECK_MISSING="grep -q 'Candidate: (none)'"
  elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
    PKG_MGR="pacman"
    PKG_FILE="packages-arch.txt"
    INSTALL_CMD="sudo pacman -S --needed --noconfirm"
    UPDATE_CMD="sudo pacman -Sy"
    CHECK_PKG="pacman -Si"
    CHECK_MISSING="grep -q 'error:'"
  else
    warn "No supported package manager found (apt/pacman)."
    warn "Set SKIP_PKG=1 to skip package installation."
    DISTRO="unknown"
  fi
  info "Detected: $DISTRO ($PKG_MGR)"
}

# ---- 1. Install packages --------------------------------------
install_packages() {
  [ "$SKIP_PKG" = "1" ] && { warn "SKIP_PKG=1 -> skipping."; return; }
  [ "$DISTRO" = "unknown" ] && { warn "Unknown distro; skipping packages."; return; }

  local pkg_file="$DOTFILES_DIR/$PKG_FILE"
  [ -f "$pkg_file" ] || { warn "Package list '$pkg_file' not found."; return; }

  info "Updating package indexes..."
  eval "$UPDATE_CMD" || true

  info "Installing packages from $PKG_FILE..."
  mapfile -t ALL_PKGS < <(grep -vE '^\s*#|^\s*$' "$pkg_file")
  PKGS=()
  for p in "${ALL_PKGS[@]}"; do
    if eval "$CHECK_PKG" "$p" 2>/dev/null | $CHECK_MISSING; then
      warn "Package '$p' not available -> skipped."
    else
      PKGS+=("$p")
    fi
  done

  if [ ${#PKGS[@]} -gt 0 ]; then
    eval "$INSTALL_CMD" "${PKGS[@]}"
    ok "Packages installed (${#PKGS[@]})"
  else
    warn "No packages to install."
  fi
}

# ---- 2. Nerd Fonts --------------------------------------------
install_nerd_font() {
  [ "$SKIP_FONT" = "1" ] && { warn "SKIP_FONT=1 -> skipping."; return; }

  if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    ok "JetBrainsMono Nerd Font already installed."
    return
  fi

  # Arch: try AUR package first
  if [ "$DISTRO" = "arch" ]; then
    if command -v yay >/dev/null 2>&1; then
      info "Installing ttf-jetbrains-mono-nerd via yay..."
      yay -S --needed --noconfirm ttf-jetbrains-mono-nerd && return
    elif command -v paru >/dev/null 2>&1; then
      info "Installing ttf-jetbrains-mono-nerd via paru..."
      paru -S --needed --noconfirm ttf-jetbrains-mono-nerd && return
    fi
    warn "No AUR helper found; falling back to manual download."
  fi

  # Manual download (both distros)
  local font_dir="$HOME/.local/share/fonts"
  info "Downloading JetBrainsMono Nerd Font..."
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
  ok "JetBrainsMono Nerd Font installed manually."
}

# ---- 3. GTK theme ---------------------------------------------
install_gtk_theme() {
  info "Setting dark theme via gsettings..."
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
  ok "GTK theme set to Adwaita-dark + Papirus-Dark."
  info "For more options: lxappearance"
}

# ---- 4. Deploy configs ----------------------------------------
deploy_configs() {
  info "Deploying configs to $CONFIG_DST..."
  mkdir -p "$CONFIG_DST"
  for dir in "$CONFIG_SRC"/*/; do
    name="$(basename "$dir")"
    [ "$name" = "i3lock" ] && continue  # handled by lock.sh
    if [ -e "$CONFIG_DST/$name" ]; then
      mkdir -p "$BACKUP_DIR"
      warn "Backing up $name -> $BACKUP_DIR/"
      mv "$CONFIG_DST/$name" "$BACKUP_DIR/"
    fi
    rm -rf "$CONFIG_DST/$name"
    cp -r "$dir" "$CONFIG_DST/$name"
    n_bad="$(find "$CONFIG_DST/$name" -type f -size 0 2>/dev/null | wc -l)"
    [ "$n_bad" -gt 0 ] && warn "WARNING: $n_bad empty file(s) in ~/.config/$name"
    ok "Installed ~/.config/$name"
  done
  chmod +x "$CONFIG_DST/polybar/launch.sh" 2>/dev/null || true
  chmod +x "$CONFIG_DST/i3/scripts/"*.sh 2>/dev/null || true
}

deploy_home() {
  local home_src="$DOTFILES_DIR/home"
  [ -d "$home_src" ] || return
  info "Deploying home files..."
  for f in "$home_src"/.*; do
    [ -f "$f" ] || continue
    local base="$(basename "$f")"
    if [ -e "$HOME/$base" ]; then
      mkdir -p "$BACKUP_DIR"
      mv "$HOME/$base" "$BACKUP_DIR/"
    fi
    cp "$f" "$HOME/$base"
    ok "Installed ~/$base"
  done
}

# ---- 5. Wallpaper ---------------------------------------------
deploy_wallpaper() {
  local wp_dir="$HOME/Pictures/wallpapers"
  mkdir -p "$wp_dir"
  if [ -f "$DOTFILES_DIR/wallpapers/cyberpunk.png" ]; then
    cp "$DOTFILES_DIR/wallpapers/cyberpunk.png" "$wp_dir/cyberpunk.png"
    ok "Wallpaper copied."
  else
    warn "No wallpaper at wallpapers/cyberpunk.png."
    warn "Place one or edit feh line in i3/config."
  fi
}

# ---- 6. Login greeter -----------------------------------------
deploy_greeter() {
  [ "$SKIP_DM" = "1" ] && { warn "SKIP_DM=1 -> skipping greeter."; return; }
  local src="$DOTFILES_DIR/system/lightdm-gtk-greeter.conf"
  local dst="/etc/lightdm/lightdm-gtk-greeter.conf"
  [ -f "$src" ] || { warn "$src not found."; return; }

  if [ -f "$DOTFILES_DIR/wallpapers/cyberpunk.png" ]; then
    sudo mkdir -p /usr/share/backgrounds
    sudo cp "$DOTFILES_DIR/wallpapers/cyberpunk.png" /usr/share/backgrounds/cyberpunk.png
    sudo chmod 644 /usr/share/backgrounds/cyberpunk.png
  fi
  [ -f "$dst" ] && [ ! -f "$dst.i3cyberpunk.bak" ] && sudo cp "$dst" "$dst.i3cyberpunk.bak"
  sudo cp "$src" "$dst"
  ok "Cyberpunk greeter applied."
}

# ---- 7. Performance tweaks (HDD-friendly) -------------------
tune_performance() {
  info "Applying performance tweaks..."
  # Reduce swappiness (HDD-friendly: write less to swap)
  if command -v sysctl >/dev/null 2>&1; then
    echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/90-cyberpunk.conf >/dev/null 2>&1 || true
    sudo sysctl -w vm.swappiness=10 >/dev/null 2>&1 || true
    ok "swappiness set to 10 (reduced disk writes)"
  fi
  # Disable picom compositing animations on low GPU (comment if smooth)
  info "Picom: xrender backend + blur strength 3 (lightweight)"
}

# ---- 8. Enable LightDM ----------------------------------------
enable_lightdm() {
  [ "$SKIP_DM" = "1" ] && { warn "SKIP_DM=1 -> skipping."; return; }
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable lightdm 2>/dev/null && ok "LightDM enabled." || warn "Could not enable lightdm."
  fi
}

# ---- Main -----------------------------------------------------
main() {
  info "== i3-cyberpunk-dotfiles installer =="
  detect_distro
  install_packages
  install_nerd_font
  install_gtk_theme
  deploy_configs
  deploy_home
  deploy_wallpaper
  tune_performance
  deploy_greeter
  enable_lightdm
  echo
  ok "Installation complete."
  [ "$DISTRO" = "arch" ] && info "AUR packages: yay -S greenclip i3lock-color"
  info "Reboot and select 'i3' in LightDM."
  info "Set fish as shell: chsh -s /usr/bin/fish"
}

main "$@"
