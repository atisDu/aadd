F_VAR=AADD_ZSH
F_TITLE="zsh + oh-my-zsh as login shell (startx on tty1 if no display manager)"
F_PKGS="zsh | zsh | zsh | zsh
git | git | git | git
curl | curl | curl | curl"
f_detect() { true; }
f_apply() {
	local omz="$HOME/.local/share/oh-my-zsh"
	[ -d "$omz" ] || run git clone -q --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$omz"
	deploy "$REPO/desktop/zshrc" "$HOME/.zshrc"
	deploy "$REPO/desktop/zprofile" "$HOME/.zprofile"
	[ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ] ||
		note "Login shell: run  chsh -s $(command -v zsh)  (asks your password)"
}
