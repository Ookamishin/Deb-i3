#!/usr/bin/env bash
# Rofi power menu
CHOICE=$(rofi -dmenu \
  -p "Power" \
  -theme ~/.config/rofi/powermenu.rasi \
  -lines 5 \
  <<< "Lock|Suspend|Reboot|Shutdown|Cancel")

case "$CHOICE" in
  Lock)     i3lock -c 0a0e14 ;;
  Suspend)  systemctl suspend ;;
  Reboot)   systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
  *)        exit 0 ;;
esac
