F_VAR=AADD_PICOM
F_TITLE="picom compositor (blur, shadows, animations)"
F_PKGS="picom | picom | picom | compositor"
# off in VMs: the glx backend there is slow or broken
f_detect() { ! systemd-detect-virt -q 2>/dev/null; }
