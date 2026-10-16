F_VAR=AADD_HOTPLUG
F_TITLE="Display menu + panel mode/DPI at login (XF86Display key)"
F_PKGS=""
f_detect() { exists /sys/class/drm/card*-eDP-* /sys/class/drm/card*-LVDS-* /sys/class/drm/card*-DSI-*; }
