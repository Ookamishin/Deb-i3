#!/usr/bin/env bash
# Wallpaper autostart — nitrogen (gui) > feh (cli)
if command -v nitrogen >/dev/null 2>&1 && [ -f ~/.config/nitrogen/bg-saved.cfg ]; then
  nitrogen --restore
elif [ -f ~/Pictures/wallpapers/cyberpunk.png ]; then
  feh --bg-fill ~/Pictures/wallpapers/cyberpunk.png
else
  feh --bg-fill ~/Pictures/wallpapers/*.png ~/Pictures/wallpapers/*.jpg 2>/dev/null || true
fi
