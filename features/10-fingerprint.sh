F_VAR=AADD_FINGERPRINT
F_TITLE="Fingerprint unlock on the lock screen"
F_PKGS="fprintd | fprintd | fprintd | fingerprint daemon"
# USB vendors that make laptop fingerprint readers: Synaptics, Goodix, Validity,
# Elan, Egis, FocalTech, AuthenTec, Upek
f_detect() {
	cat /sys/bus/usb/devices/*/idVendor 2>/dev/null | grep -qxE '06cb|27c6|138a|04f3|1c7a|2808|08ff|147e'
}
f_apply() {
	note "Fingerprint: enroll as YOURSELF after logging in to dwm (polkit asks for your password):
    fprintd-enroll
  Not 'sudo fprintd-enroll' - that enrolls the finger for root."
}
