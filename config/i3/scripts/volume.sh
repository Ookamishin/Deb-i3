#!/usr/bin/env bash
# Volume control with dunst notification
# Usage: ./volume.sh up|down|mute
SINK=@DEFAULT_SINK@

case "$1" in
  up)   pactl set-sink-volume "$SINK" +5% ;;
  down) pactl set-sink-volume "$SINK" -5% ;;
  mute) pactl set-sink-mute "$SINK" toggle ;;
  *)    exit 1 ;;
esac

VOL=$(pactl get-sink-volume "$SINK" | awk '{print $5}' | tr -d '%')
MUTED=$(pactl get-sink-mute "$SINK" | grep -c 'yes')

if [ "$MUTED" -eq 1 ]; then
  dunstify -a "volume" -u low -h int:value:0 "Volume muted" -i audio-volume-muted
else
  dunstify -a "volume" -u low -h int:value:"$VOL" "Volume: ${VOL}%" -i audio-volume-high
fi
