# Distro detection and package installation.
# DISTRO is one of: arch debian fedora (the column used in packages/*.list).

detect_distro() {
	[ -r /etc/os-release ] || die "no /etc/os-release: can't tell which distro this is"
	. /etc/os-release
	DISTRO_NAME=${PRETTY_NAME:-$ID}
	case " $ID ${ID_LIKE:-} " in
		*" arch "*)                DISTRO=arch ;;
		*" debian "*|*" ubuntu "*) DISTRO=debian ;;
		*" fedora "*|*" rhel "*)   DISTRO=fedora ;;
		*) die "unsupported distro: $DISTRO_NAME (supported: Arch, Debian/Ubuntu, Fedora and their derivatives)" ;;
	esac
}

# pkg_column LINE: the package name for this distro from an "arch | debian | fedora | desc" line
pkg_column() {
	local arch deb fed
	IFS='|' read -r arch deb fed _ <<<"$1"
	case $DISTRO in
		arch) echo $arch ;; debian) echo $deb ;; fedora) echo $fed ;;
	esac
}

pkg_refresh() {
	case $DISTRO in
		arch)   srun pacman -Syu --noconfirm ;;   # never -Sy alone: partial upgrades break Arch
		debian) srun apt-get update -q ;;
		fedora) : ;;   # dnf refreshes metadata on its own
	esac
}

# pkg_install NAME...: install what the repos have; on Arch the rest comes from the AUR.
# Missing packages are reported, never fatal.
pkg_install() {
	local p repo=() aur=() missing=()
	for p in $(printf '%s\n' "$@" | sort -u); do
		[ "$p" = - ] && continue
		if pkg_installed "$p"; then continue; fi
		if pkg_available "$p"; then repo+=("$p")
		elif [ $DISTRO = arch ]; then aur+=("$p")
		else missing+=("$p"); fi
	done
	[ ${#missing[@]} -gt 0 ] && fail "not in the $DISTRO_NAME repos, skipped: ${missing[*]}"
	if [ ${#repo[@]} -gt 0 ]; then
		log "installing: ${repo[*]}"
		case $DISTRO in
			arch)   srun pacman -S --needed --noconfirm "${repo[@]}" ;;
			debian) srun env DEBIAN_FRONTEND=noninteractive apt-get install -y "${repo[@]}" ;;
			fedora) srun dnf install -y "${repo[@]}" ;;
		esac
	fi
	if [ ${#aur[@]} -gt 0 ]; then
		aur_helper || { fail "no AUR helper, skipped: ${aur[*]}"; return; }
		log "installing from the AUR: ${aur[*]}"
		run "$AUR" -S --needed --noconfirm "${aur[@]}"
	fi
}

pkg_installed() {
	case $DISTRO in
		arch)   pacman -Qq "$1" >/dev/null 2>&1 || pacman -Qqg "$1" >/dev/null 2>&1 ;;
		debian) dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'ok installed' ;;
		fedora) [[ $1 == @* ]] && return 1; rpm -q "$1" >/dev/null 2>&1 ;;
	esac
}

pkg_available() {
	case $DISTRO in
		arch)   pacman -Si "$1" >/dev/null 2>&1 || pacman -Sg "$1" >/dev/null 2>&1 ;;
		debian) apt-cache show "$1" >/dev/null 2>&1 ;;
		fedora) dnf -q info "$1" >/dev/null 2>&1 || [[ $1 == @* ]] ;;
	esac
}

# aur_helper: set AUR to paru/yay, building paru-bin first if neither exists
aur_helper() {
	AUR=$(command -v paru || command -v yay) && return 0
	[ "$DRY_RUN" = 1 ] && { AUR=paru; echo "   would build paru-bin from the AUR"; return 0; }
	log "building paru (AUR helper)"
	srun pacman -S --needed --noconfirm base-devel git || return 1
	local d; d=$(mktemp -d)
	git clone -q https://aur.archlinux.org/paru-bin.git "$d" && (cd "$d" && makepkg -si --noconfirm) ||
		{ rm -rf "$d"; return 1; }
	rm -rf "$d"
	AUR=$(command -v paru)
}
