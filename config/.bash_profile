[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

_cdf() {
	cd "$(find ~/dev/ -type d \( -name .git -o -name node_modules -o -name dist -o -name .next -o -name docker-volume* \) -prune -o -type d -print | fzf --height=40% --layout=reverse)"
}
