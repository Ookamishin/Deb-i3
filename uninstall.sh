#!/usr/bin/env bash
# =============================================================
#  i3-cyberpunk-dotfiles uninstaller
#  Removes deployed configs and (optionally) packages.
#  Does NOT delete your backups.
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

# ---- 1. Restore latest backup ---------------------------------
restore_or_remove_configs() {
  info "Removing configs installed by this project..."
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
        ok "Restored backup of $name from $latest_backup"
      fi
    fi
  done
}

# ---- 2. Remove Nerd Font (optional) ---------------------------
remove_font() {
  [ "$REMOVE_FONT" != "1" ] && return
  local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
  if [ -d "$font_dir" ]; then
    rm -rf "$font_dir"
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null || true
    ok "Nerd Font removed."
  fi
}

# ---- 3. Revert login greeter ----------------------------------
revert_greeter() {
  local dst="/etc/lightdm/lightdm-gtk-greeter.conf"
  if ! command -v sudo >/dev/null 2>&1; then return; fi
  if [ -f "$dst.i3cyberpunk.bak" ]; then
    sudo mv "$dst.i3cyberpunk.bak" "$dst"
    ok "Previous greeter restored from backup."
  elif [ -f "$dst" ]; then
    warn "No greeter backup found; leaving current config."
  fi
  [ -f /usr/share/backgrounds/cyberpunk.png ] && sudo rm -f /usr/share/backgrounds/cyberpunk.png || true
}

# ---- 4. Purge packages (optional) -----------------------------
purge_packages() {
  [ "$PURGE_PACKAGES" != "1" ] && return
  if ! command -v apt >/dev/null 2>&1; then
    warn "apt not available; skipping package removal."
    return
  fi
  warn "You are about to REMOVE packages from packages.txt (includes xorg, i3, etc.)."
  if confirm "Are you sure you want to remove these packages?"; then
    mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages.txt")
    sudo apt remove -y "${PKGS[@]}" || warn "Some packages could not be removed."
    sudo apt autoremove -y || true
    ok "Packages removed."
  else
    info "Package removal cancelled."
  fi
}

main() {
  info "== i3-cyberpunk-dotfiles uninstaller =="
  if ! confirm "This will remove configs in ~/.config from this project. Continue?"; then
    info "Cancelled."
    exit 0
  fi
  restore_or_remove_configs
  remove_font
  revert_greeter
  purge_packages
  echo
  ok "Uninstall complete."
  info "Your backups (~/.config-backup-*) have NOT been deleted."
  info "To disable LightDM: sudo systemctl disable lightdm"
}

main "$@"
