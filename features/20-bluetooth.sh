F_VAR=AADD_BLUETOOTH
F_TITLE="Bluetooth (btmenu on Mod+Shift+B, connect notifications)"
F_PKGS="bluez | bluez | bluez | bluetooth stack
bluez-utils | bluez | bluez | bluetoothctl"
f_detect() { exists /sys/class/bluetooth/hci*; }
f_apply() { enable_service bluetooth.service; }
