#!/usr/bin/env bash
# =============================================================
#  i3-cyberpunk-dotfiles uninstaller (multi-distro)
# =============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DST="$HOME/.config"

PURGE_PACKAGES="${PURGE_PACKAGES:-0}"
REMOVE_FONT="${REMOVE_FONT:-0}"
ASSUME_YES="${ASSUME_YES:-0}"

info()  { printf "\033[0;36m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[+]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

confirm() {
  [ "$ASSUME_YES" = "1" ] && return 0
  read -r -p "$1 [y/N] " ans
  case "$ans" in [yY]) return 0 ;; *) return 1 ;; esac
}

detect_distro() {
  if command -v apt >/dev/null 2>&1; then
    DISTRO="debian"
    PKG_FILE="packages.txt"
    REMOVE_CMD="sudo apt remove -y"
    AUTOREMOVE_CMD="sudo apt autoremove -y"
  elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
    PKG_FILE="packages-arch.txt"
    REMOVE_CMD="sudo pacman -Rns --noconfirm"
    AUTOREMOVE_CMD="sudo pacman -Rns --noconfirm $(pacman -Qdtq 2>/dev/null || true)"
  else
    DISTRO="unknown"
  fi
}

# ---- 1. Restore backup -----------------------------------------
restore_or_remove_configs() {
  info "Removing configs..."
  local latest_backup
  latest_backup="$(ls -1d "$HOME"/.config-backup-* 2>/dev/null | sort | tail -n1 || true)"

  for dir in "$CONFIG_SRC"/*/; do
    name="$(basename "$dir")"
    target="$CONFIG_DST/$name"
    if [ -e "$target" ]; then
      rm -rf "$target"
      ok "Removed ~/.config/$name"
      if [ -n "$latest_backup" ] && [ -e "$latest_backup/$name" ]; then
        cp -r "$latest_backup/$name" "$target"
        ok "Restored backup of $name"
      fi
    fi
  done
}

# ---- 2. Remove Nerd Font ---------------------------------------
remove_font() {
  [ "$REMOVE_FONT" != "1" ] && return
  local dirs
  dirs="$HOME/.local/share/fonts/JetBrainsMono /usr/share/fonts/JetBrainsMono"
  for d in $dirs; do
    [ -d "$d" ] && sudo rm -rf "$d" 2>/dev/null || true
  done
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null || true
  ok "Nerd Font removed."
}

# ---- 3. Revert greeter -----------------------------------------
revert_greeter() {
  local dst="/etc/lightdm/lightdm-gtk-greeter.conf"
  if ! command -v sudo >/dev/null 2>&1; then return; fi
  if [ -f "$dst.i3cyberpunk.bak" ]; then
    sudo mv "$dst.i3cyberpunk.bak" "$dst"
    ok "Previous greeter restored."
  fi
  [ -f /usr/share/backgrounds/cyberpunk.png ] && sudo rm -f /usr/share/backgrounds/cyberpunk.png || true
}

# ---- 4. Purge packages -----------------------------------------
purge_packages() {
  [ "$PURGE_PACKAGES" != "1" ] && return
  [ "$DISTRO" = "unknown" ] && { warn "Unknown distro; skip."; return; }

  local pkg_file="$DOTFILES_DIR/$PKG_FILE"
  [ -f "$pkg_file" ] || { warn "$pkg_file not found."; return; }

  warn "You are about to REMOVE packages from $PKG_FILE (includes xorg, i3, etc.)."
  if confirm "Are you sure?"; then
    mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$pkg_file")
    eval "$REMOVE_CMD" "${PKGS[@]}" || warn "Some could not be removed."
    eval "$AUTOREMOVE_CMD" || true
    ok "Packages removed."
  fi
}

main() {
  detect_distro
  info "== i3-cyberpunk-dotfiles uninstaller ($DISTRO) =="
  if ! confirm "Remove configs in ~/.config from this project?"; then
    info "Cancelled."; exit 0
  fi
  restore_or_remove_configs
  remove_font
  revert_greeter
  purge_packages
  echo
  ok "Done. Backups (~/.config-backup-*) not deleted."
  info "To disable LightDM: sudo systemctl disable lightdm"
}

main "$@"
