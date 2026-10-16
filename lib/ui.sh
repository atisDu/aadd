# ncurses menus via dialog(1). Every function prints the choice on stdout and
# returns non-zero on Cancel/Esc, which ./aadd treats as "quit".

DIALOG_OPTS=(--stdout --backtitle "aadd - Atis's automated desktop deploy")

ui_msg()   { dialog "${DIALOG_OPTS[@]}" --title "$1" --msgbox "$2" 0 0; }
ui_yesno() { dialog "${DIALOG_OPTS[@]}" --title "$1" --yesno "$2" 0 0; }
ui_input() { dialog "${DIALOG_OPTS[@]}" --title "$1" --inputbox "$2" 0 0 "$3"; }

# ui_radio TITLE TEXT TAG DESC on|off ...
ui_radio() {
	local t="$1" x="$2"; shift 2
	dialog "${DIALOG_OPTS[@]}" --title "$t" --radiolist "$x" 0 0 0 "$@"
}

# ui_check TITLE TEXT TAG DESC on|off ...  -> selected tags, one per line
ui_check() {
	local t="$1" x="$2"; shift 2
	dialog "${DIALOG_OPTS[@]}" --separate-output --title "$t" --checklist "$x" 0 0 0 "$@"
}

# make sure dialog exists before the first menu (plain prompt, no ncurses yet)
ui_bootstrap() {
	command -v dialog >/dev/null && return 0
	printf 'aadd needs "dialog" for its menus. Install it now? [Y/n] '
	read -r a; case $a in [nN]*) die "dialog is required" ;; esac
	case $DISTRO in
		arch)   sudo pacman -S --needed --noconfirm dialog ;;
		debian) sudo apt-get update -q && sudo apt-get install -y dialog ;;
		fedora) sudo dnf install -y dialog ;;
	esac || die "couldn't install dialog"
}
