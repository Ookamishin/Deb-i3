#!/usr/bin/env bash
# =============================================================
#  i3-nord-dotfiles uninstaller
#  Elimina las configuraciones desplegadas y (opcional) los
#  paquetes instalados. NO borra tus backups.
# =============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DST="$HOME/.config"

# Toggles:
#   PURGE_PACKAGES=1 -> tambien desinstala los paquetes de packages.txt
#   REMOVE_FONT=1    -> tambien elimina la Nerd Font instalada
#   ASSUME_YES=1     -> no pide confirmacion
PURGE_PACKAGES="${PURGE_PACKAGES:-0}"
REMOVE_FONT="${REMOVE_FONT:-0}"
ASSUME_YES="${ASSUME_YES:-0}"

info()  { printf "\033[0;36m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[+]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

confirm() {
  [ "$ASSUME_YES" = "1" ] && return 0
  read -r -p "$1 [s/N] " ans
  case "$ans" in [sSyY]) return 0 ;; *) return 1 ;; esac
}

# ---- 1. Restaurar backup mas reciente (si existe) ------------
restore_or_remove_configs() {
  info "Eliminando configuraciones instaladas por este proyecto..."
  local latest_backup
  latest_backup="$(ls -1d "$HOME"/.config-backup-* 2>/dev/null | sort | tail -n1 || true)"

  for dir in "$CONFIG_SRC"/*/; do
    name="$(basename "$dir")"
    target="$CONFIG_DST/$name"
    if [ -e "$target" ]; then
      rm -rf "$target"
      ok "Eliminado ~/.config/$name"
      # Si hay backup de ese componente, lo restauramos
      if [ -n "$latest_backup" ] && [ -e "$latest_backup/$name" ]; then
        cp -r "$latest_backup/$name" "$target"
        ok "Restaurado backup de $name desde $latest_backup"
      fi
    fi
  done
}

# ---- 2. Eliminar Nerd Font (opcional) -----------------------
remove_font() {
  [ "$REMOVE_FONT" != "1" ] && return
  local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
  if [ -d "$font_dir" ]; then
    rm -rf "$font_dir"
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null || true
    ok "Nerd Font eliminada."
  fi
}

# ---- 3. Desinstalar paquetes (opcional) ---------------------
purge_packages() {
  [ "$PURGE_PACKAGES" != "1" ] && return
  if ! command -v apt >/dev/null 2>&1; then
    warn "apt no disponible; omito desinstalación de paquetes."
    return
  fi
  warn "Vas a DESINSTALAR los paquetes de packages.txt (incluye xorg, i3, etc.)."
  if confirm "¿Seguro que quieres eliminar esos paquetes del sistema?"; then
    mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages.txt")
    sudo apt remove -y "${PKGS[@]}" || warn "Algunos paquetes no se pudieron eliminar."
    sudo apt autoremove -y || true
    ok "Paquetes eliminados."
  else
    info "Desinstalación de paquetes cancelada."
  fi
}

main() {
  info "== i3-nord-dotfiles uninstaller =="
  if ! confirm "Esto eliminará las configs de este proyecto en ~/.config. ¿Continuar?"; then
    info "Cancelado."
    exit 0
  fi
  restore_or_remove_configs
  remove_font
  purge_packages
  echo
  ok "Desinstalación completa."
  info "Tus backups (~/.config-backup-*) NO se han borrado."
  info "Si habilitaste LightDM y quieres revertirlo: sudo systemctl disable lightdm"
}

main "$@"
