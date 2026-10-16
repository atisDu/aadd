F_VAR=AADD_WIFI
F_TITLE="Wi-Fi (wifimenu on Mod+Shift+R)"
F_PKGS="networkmanager | network-manager | NetworkManager | NetworkManager"
f_detect() { exists /sys/class/net/*/wireless; }
f_apply() { enable_service NetworkManager.service; }
