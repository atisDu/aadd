# Shared helpers: logging, dry-run, backups, template rendering.
# Sourced by ./aadd; expects REPO (repo path), BACKUP_DIR, DRY_RUN.

LOG="${XDG_STATE_HOME:-$HOME/.local/state}/aadd/aadd.log"
NOTES=()     # shown at the end: manual steps
FAILED=()    # shown at the end: things that didn't work, nothing aborts on them

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; printf '%s %s\n' "$(date +%T)" "$*" >>"$LOG"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; printf '%s WARN %s\n' "$(date +%T)" "$*" >>"$LOG"; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }
note() { NOTES+=("$*"); }
fail() { FAILED+=("$*"); warn "$*"; }

# run CMD...: execute, or only print it with --dry-run. Failures are recorded, not fatal.
run() {
	if [ "$DRY_RUN" = 1 ]; then
		printf '   would run: %s\n' "$*"
		return 0
	fi
	printf '%s $ %s\n' "$(date +%T)" "$*" >>"$LOG"
	"$@" || { fail "failed: $*"; return 1; }
}
srun() { run sudo "$@"; }

exists() { local p; for p; do [ -e "$p" ] && return 0; done; return 1; }

# backup PATH: move it under BACKUP_DIR, keeping its path relative to $HOME
backup() {
	local rel="${1#"$HOME"/}" dest
	dest="$BACKUP_DIR/$rel"
	run mkdir -p "$(dirname "$dest")" && run mv "$1" "$dest" && log "backed up ~/$rel"
}

# render FILE: print it with every @VAR@ replaced by the value of $VAR
# (AADD_* from aadd.conf, plus HOME). Unknown @AADD_X@ are left and warned about.
shopt -u patsub_replacement 2>/dev/null   # bash 5.2: keep & literal in ${x//a/b}
render() {
	local s v
	IFS= read -r -d '' s <"$1"   # whole file, trailing newlines kept byte-exact
	if [[ $s == *@* ]]; then
		for v in HOME $(compgen -v AADD_); do
			s=${s//@$v@/${!v}}
		done
		[[ $s =~ @AADD_[A-Z_]+@ ]] && warn "$1: no value for ${BASH_REMATCH[0]}"
	fi
	printf '%s' "$s"
}

# deploy SRC DEST: render SRC to DEST. An existing different DEST is backed up
# first; an identical one is left alone. Keeps the executable bit.
deploy() {
	local src="$1" dest="$2" tmp
	tmp=$(mktemp)
	render "$src" >"$tmp"
	if [ -e "$dest" ] && cmp -s "$tmp" "$dest"; then
		rm -f "$tmp"; return 0
	fi
	if [ "$DRY_RUN" = 1 ]; then
		printf '   would write: %s%s\n' "${dest/#$HOME/\~}" "$([ -e "$dest" ] && echo ' (backing up the old one)')"
		rm -f "$tmp"; return 0
	fi
	[ -e "$dest" ] && backup "$dest"
	mkdir -p "$(dirname "$dest")"
	install -m "$([ -x "$src" ] && echo 755 || echo 644)" "$tmp" "$dest"
	rm -f "$tmp"
}

# deploy_tree SRCDIR DESTDIR: deploy every file under SRCDIR
deploy_tree() {
	local f
	while IFS= read -r -d '' f; do
		deploy "$f" "$2/${f#"$1"/}"
	done < <(find "$1" -type f -print0)
}

enable_service() {
	command -v systemctl >/dev/null || return 0
	systemctl list-unit-files "$1" >/dev/null 2>&1 || { warn "no $1 on this system"; return 0; }
	srun systemctl enable --now "$1"
}

add_group() {
	getent group "$1" >/dev/null || return 0
	id -nG "$USER" | tr ' ' '\n' | grep -qx "$1" && return 0
	srun usermod -aG "$1" "$USER" && note "Added you to group '$1': log out and back in for it to apply."
}
