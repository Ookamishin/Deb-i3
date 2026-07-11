#!/usr/bin/env bash
# Random cyberpunk wallpaper from ~/Pictures/wallpapers/
DIR=~/Pictures/wallpapers
[ -d "$DIR" ] || { echo "No wallpaper dir"; exit 1; }

# Use feh to pick a random image
feh --bg-fill --randomize "$DIR"/*.png "$DIR"/*.jpg 2>/dev/null

# Notify
dunstify -a "wallpaper" -u low "Wallpaper changed"
