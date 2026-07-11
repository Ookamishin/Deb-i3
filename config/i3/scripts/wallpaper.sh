#!/usr/bin/env bash
# Wallpaper manager — random from ~/Pictures/wallpapers/
# Uses nitrogen first (saves config), falls back to feh
DIR=~/Pictures/wallpapers
[ -d "$DIR" ] || { mkdir -p "$DIR"; exit 0; }

# Pick a random image
IMG=$(find "$DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n1)
[ -z "$IMG" ] && { dunstify -a "wallpaper" -u critical "No wallpapers found"; exit 1; }

if command -v nitrogen >/dev/null 2>&1; then
  nitrogen --set-zoom-fill "$IMG" --save
else
  feh --bg-fill "$IMG"
fi

dunstify -a "wallpaper" -u low "Wallpaper: $(basename "$IMG")"
