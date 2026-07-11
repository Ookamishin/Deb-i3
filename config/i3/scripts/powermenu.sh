#!/usr/bin/env bash
# Rofi power menu — Shutdown · Reboot · Hibernate · Logout · Lock · Suspend
CHOICE=$(rofi -dmenu \
  -p "Power" \
  -theme ~/.config/rofi/powermenu.rasi \
  -lines 7 \
  <<< "Shutdown|Reboot|Hibernate|Logout|Lock|Suspend|Cancel")

case "$CHOICE" in
  Shutdown)  systemctl poweroff ;;
  Reboot)    systemctl reboot ;;
  Hibernate) systemctl hibernate ;;
  Logout)    i3-msg exit ;;
  Lock)      i3lock -c 0a0e14 ;;
  Suspend)   systemctl suspend ;;
  *)         exit 0 ;;
esac
