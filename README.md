# aadd: Atis's automated desktop deploy

One script that takes a fresh Linux install (or an existing one) to my
desktop: package sets plus a dwm desktop with my dmenu, slstatus, scripts and
dotfiles. It's menu driven (ncurses `dialog`, `[X]` checkboxes) and works on
**Arch** (incl. CachyOS/EndeavourOS/Manjaro), **Debian/Ubuntu** and **Fedora**.

```sh
git clone https://github.com/atisDu/aadd && cd aadd
./aadd --dry-run   # walk the menus, print what would happen, change nothing
./aadd
```

Run it as your normal user, not root. It asks for sudo when it needs it.
**Create the user, set passwords, git identity and SSH keys yourself.** aadd
never touches them, and this repo holds no private data.

## What the menus ask

1. **Machine**: *fresh install*, or *already set up*. On an existing machine
   the package categories start unticked, and every config file that would be
   overwritten is first moved to `~/.local/state/aadd/backups/<date>/`. The
   folder layout under `$HOME` is kept, so restoring is a `cp -r`. A fresh
   install gets the same protection, so a rerun never loses anything.
2. **Packages**: categories (base, productivity, coding, media, gaming,
   system), then the packages in each. Names are mapped per distro. Anything not
   packaged on the detected distro is left out of the menu. On Arch, packages
   that aren't in the repos are built from the AUR (paru is set up if needed).
3. **Desktop config**: build and install dwm/dmenu/slstatus, the scripts and the
   dotfiles.
4. **Hardware & features**: each item is preselected if the hardware was
   detected, and you can untick it. A feature that's off is compiled out of
   dwm/slstatus (its keybinds and bar items are gone) and skipped by the
   scripts, so a machine without a fingerprint reader, Bluetooth or a battery
   gets no errors:
   | feature | adds |
   |---|---|
   | fingerprint | fprintd unlock on the lock screen |
   | bluetooth | `btmenu` (Mod+Shift+B), connect notifications |
   | wifi | `wifimenu` (Mod+Shift+R), NetworkManager |
   | laptop | battery, brightness keys/bar item, power profiles (Mod+Shift+E) |
   | hotplug | `screenmenu` (XF86Display), panel mode + DPI at login |
   | picom | compositor (off by default in VMs) |
   | stt | Whisper dictation on the Intel NPU (Mod+U) |
   | zsh | zsh + oh-my-zsh, `startx` on tty1 when there's no display manager |
5. **Machine profile** (only when the DMI name matches one in `profiles/`),
   **display scale** (fonts, DPI and cursor all follow it), **keyboard layout**,
   **wallpaper folder**.

Your answers are saved to `~/.config/aadd/aadd.conf`, and a rerun starts from
them. Edit that file and rerun `./aadd` to change anything.

## Where things go

| what | where |
|---|---|
| dwm, dmenu, slstatus sources | `~/.local/src/{dwm,dmenu,slstatus}` |
| their binaries | `/usr/local/bin` |
| desktop scripts (lock, menus, ...) | `~/.local/bin` |
| dotfiles | `~/.config/...`, `~/.xinitrc`, `~/.Xresources`, `~/.zshrc` |
| aadd settings | `~/.config/aadd/aadd.conf` |
| your machine-only X tweaks (never overwritten) | `~/.config/aadd/xinitrc.local` |
| your zsh additions (never overwritten) | `~/.config/aadd/zshrc.local` |
| backups, log | `~/.local/state/aadd/` |
| display-manager session | `/usr/share/xsessions/dwm.desktop` |

## Repo layout

```
aadd                  entry point: menus, then the steps in order
lib/                  common (log, backup, render), distro, ui, suckless
packages/*.list       package categories: "arch | debian | fedora | description"
features/*.sh         optional features: detection, packages, setup step
profiles/<model>/     per-model hardware tweaks (panel mode, input devices)
desktop/              dotfiles and scripts, deployed with @AADD_*@ filled in
suckless/<name>/      pinned commit + patch + config.h for dwm, dmenu, slstatus
```

## Extending

- **Package category**: add `packages/<name>.list`. Line 1 is `## Title`, and
  `## off` on line 2 makes it unticked by default.
- **Feature**: add `features/NN-name.sh` (see `features/README`), then gate on it
  with `@AADD_NAME@`: `[ "@AADD_NAME@" = 1 ]` in shell, or
  `#if AADD_NAME` after a `#define AADD_NAME @AADD_NAME@` in a config.h.
- **Machine**: add `profiles/<model>/profile.conf` with `P_MATCH` (from
  `/sys/class/dmi/id/product_version`) and optional `xinitrc.local`.
- **dwm/dmenu changes**: edit them in `~/.local/src/<name>`, then refresh
  `suckless/<name>/<name>.patch` (`git diff`) and `config.h` here.

## Notes

- Fingerprint: enroll as yourself after logging in (`fprintd-enroll`, and polkit
  asks for your password). `sudo fprintd-enroll` enrolls the finger for root.
- On plain Arch, a few packages (vscodium, heroic, i3lock-color) come from the
  AUR and compile, which takes a while. CachyOS has them prebuilt.
- Debian/Fedora have no i3lock-color: the lock screen falls back to plain i3lock.
  Steam and Telegram need extra repos there (contrib/i386, RPM Fusion/Flathub).
