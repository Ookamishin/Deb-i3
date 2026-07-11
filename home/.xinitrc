#!/usr/bin/env bash
# ~/.xinitrc — start i3 with cyberpunk config
if [ -f /etc/X11/xinit/xinitrc.d/30-dbus ]; then
    . /etc/X11/xinit/xinitrc.d/30-dbus
fi

# Set keyboard layout (adjust as needed)
setxkbmap us

# Start i3
exec i3
