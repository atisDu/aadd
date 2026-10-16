# Build dwm, dmenu and slstatus from Atis's forks.
# Each suckless/<name>/ holds:
#   pin           commit of github.com/atisDu/<name> the patch was made against
#   <name>.patch  optional local changes on top of that commit
#   config.h      template, rendered with aadd.conf values
# Sources live in ~/.local/src/<name>; the binaries go to /usr/local/bin.

SUCKLESS_GIT=https://github.com/atisDu

build_suckless() {
	local name="$1" dir="$REPO/suckless/$1" src="$HOME/.local/src/$1"
	log "building $name"
	[ -e "$src" ] && backup "$src"
	run git clone -q "$SUCKLESS_GIT/$name.git" "$src" || return
	run git -C "$src" checkout -q "$(cat "$dir/pin")" || return
	[ -f "$dir/$name.patch" ] && { run git -C "$src" apply "$dir/$name.patch" || return; }
	if [ "$DRY_RUN" = 1 ]; then
		echo "   would render config.h and make install"
		return
	fi
	render "$dir/config.h" >"$src/config.h"
	run make -C "$src" clean >/dev/null &&
		run make -C "$src" >/dev/null &&
		srun make -C "$src" install >/dev/null
}
