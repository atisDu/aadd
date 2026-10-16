F_VAR=AADD_LAPTOP
F_TITLE="Laptop: battery, brightness keys, power profiles (Mod+Shift+E)"
F_PKGS="brightnessctl | brightnessctl | brightnessctl | backlight control
power-profiles-daemon | power-profiles-daemon | power-profiles-daemon | power profiles"
f_detect() { exists /sys/class/power_supply/BAT* /sys/class/backlight/*; }
f_apply() { enable_service power-profiles-daemon.service; }
