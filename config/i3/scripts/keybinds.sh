#!/usr/bin/env bash
# Show keybindings in rofi
cat ~/.config/i3/keybinds.txt | rofi -dmenu -p "Keybinds" -theme ~/.config/rofi/cyberpunk.rasi -lines 25
