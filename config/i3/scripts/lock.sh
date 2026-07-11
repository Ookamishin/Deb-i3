#!/usr/bin/env bash
# Cyberpunk lockscreen via i3lock-color
# Requires: i3lock-color, imagemagick
WALLPAPER=~/Pictures/wallpapers/cyberpunk.png
[ -f "$WALLPAPER" ] || exit 1
TMPBG=/tmp/lock.png

# Scale, blur, darken, add cyan tint
convert "$WALLPAPER" \
  -resize 1920x1080^ \
  -gravity center -extent 1920x1080 \
  -blur 0x8 \
  -fill '#0a0e14' -colorize 40% \
  "$TMPBG"

i3lock \
  --image "$TMPBG" \
  --inside-color='0a0e14ff' \
  --ring-color='00f0ffff' \
  --line-color='0a0e1400' \
  --keyhl-color='ff007fff' \
  --bshl-color='ff0040ff' \
  --separator-color='0a0e1400' \
  --insidever-color='0a0e14ff' \
  --insidewrong-color='0a0e14ff' \
  --ringver-color='7c3aedff' \
  --ringwrong-color='ff0040ff' \
  --verif-color='00f0ffff' \
  --wrong-color='ff0040ff' \
  --layout-color='c0caf5ff' \
  --time-color='00f0ffff' \
  --date-color='c0caf5ff' \
  --time-str='%H:%M' \
  --date-str='%A, %d %B' \
  --time-font='JetBrainsMono Nerd Font' \
  --date-font='JetBrainsMono Nerd Font' \
  --time-size=48 \
  --date-size=16 \
  --radius=120 \
  --ring-width=4 \
  --ind-pos='x+w/2:y+h/2-40' \
  --time-pos='x+w/2:y+h/2+80' \
  --date-pos='x+w/2:y+h/2+110' \
  --greeter-pos='x+w/2:y+h/2+140' \
  --pass-media-keys \
  --pass-screen-keys \
  --pass-volume-keys

rm -f "$TMPBG"
