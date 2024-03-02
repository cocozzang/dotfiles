echo "excute bash profile"

[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

_cdf() {
	[ -z "$1" ] &&
		cd "$(find ~ -type d \( -name .git -o -name node_modules -o -name dist -o -name .next \) -prune -o -print | fzf --height=40% --layout=reverse)" ||
		cd "$(find "$1" -type d \( -name .git -o -name node_modules -o -name dist -o -name .next \) -prune -o -print | fzf --height=40% --layout=reverse)"
}
