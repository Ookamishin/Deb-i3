#!/usr/bin/env bash
# Launch polybar on every connected monitor

# Terminate already running bar instances
pkill -x polybar 2>/dev/null || true
# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar on each monitor
if type "xrandr" >/dev/null 2>&1; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main &
  done
else
  polybar --reload main &
fi

echo "Polybar launched..."
