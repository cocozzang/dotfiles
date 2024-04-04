#!/bin/bash

declare -a common_packages=(
	git curl wget fzf fd-find ripgrep tree xclip ca-certificates gnupg
)

# https://github.com/neovim/neovim/blob/master/INSTALL.md#linux
install_neovim() {
	sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
	sudo rm -rf /opt/nvim
	sudo tar -C /opt -xzf nvim-linux64.tar.gz
	sudo rm -f nvim-linux64.tar.gz
}

# https://github.com/jesseduffield/lazygit?tab=readme-ov-file#ubuntu
install_lazygit() {
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	sudo curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	sudo tar xf lazygit.tar.gz lazygit
	sudo install lazygit /usr/local/bin
}

# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
install_nvm() {
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

# https://docs.docker.com/engine/install/ubuntu/
install_docker() {
	# Add Docker's official GPG key:
	sudo apt-get update
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
		sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
	sudo apt-get update

	# install docker
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_ohmyposh() {
	curl -s https://ohmyposh.dev/install.sh | bash -s
}

install_rust() {
	curl https://sh.rustup.rs -sSf | sh
}

install_packages() {
	install_neovim
	install_lazygit
	install_nvm
	install_docker
	install_ohmyposh
	install_rust
	sudo apt update && apt install "${common_packages[@]}"
}

declare -a config_dirs=(
	"nvim" "lazygit"
)

declare -a home_files=(
	".bashrc" ".bash_profile" ".bash_aliases" ".gitconfig"
)

setup_symlink() {
	echo -e "\x1b[2;30;103m symlink 조지는중 0ㅅ0 \x1b[0m"

	for dir in "${config_dirs[@]}"; do
		ln -sfnv "$PWD/config/$dir" "~/.config/"
	done

	for file in "${home_files[@]}"; do
		ls -sfnv "$PWD/config/$file" ~/
	done
}

backup_configs() {
	echo -e "\e[33;1m Backing up existing files... \e[0m"
	for dir in "${config_dirs[@]}"; do
		mv -v "$HOME/.config/$dir" "$HOME/.config/$dir.old"
	done
	for file in "${home_files[@]}"; do
		mv -v "$HOME/$file" "$HOME/$file.old"
	done
	echo -e "\e[36;1m Remove backups with 'rm -ir ~/.*.old && rm -ir ~/.config/*.old'. \e[0m"
}

# generate ssh for github
gen_ssh() {
	ssh-keygen -t rsa -b 4096 -C "cocozz503@naver.com"
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_rsa
	cat ~/.ssh/id_rsa.pub
	echo ~/.ssh/id_rsa.pub | xclip -sel clip
	echo -e "\e[2;30;103m ssh 공개키가 클립보드에 복사되었습니다. github에 등록하세요 \e[0m \n"
	read -p "등록이 완료되었으면 Enter를 눌러 계속"
}

# https://docs.github.com/ko/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
gen_gpg() {
	gpg --full-generate-key
	gpg --list-secret-keys --keyid-format=long
	echo "gpg --armor --export [key] 를 입력하고 해당 출력을 github에 등록하세요."
	echo "git config --global user.signingkey [key]로 gitconfig파일에 public gpg key추가하기"
	read -p "등록이 완료되었으면 Enter를 눌러 계속"
}

# https://github.com/bfrg/gpg-guide/blob/master/gpg-agent.conf
# gpg password 입력주기 늘리기 default는 600초임
gen_gpg_agent_conf() {
	if [[ -d ~/.gnupg ]]; then
		echo -e "default-cache-ttl 86400  # 24시간\nmax-cache-ttl 86400  # 24시간" >>~/.gnupg/gpg-agent.conf
		sleep 1
		gpg-connect-agent reloadagent
	else
		echo -e "\e[1;91m ~/.gnupg 폴더가 존재하지 않습니다. gpg키 생성이 완료되었는지 확인해주세요.  \e[0m \n"
	fi
}

gen_secret() {
	gen_ssh
	gen_gpg
	gen_gpg_agent_conf
}

nerd_font_info() {
	echo -e "\e[2;30;103m \e[4mhttps://www.nerdfonts.com/font-downloads\e[24m 에서 MesloLGLNerdFont를 다운받고 \e[0m
\e[2;30;103m window terminal emulator내의 ubuntu profile font를 MesloLGL Nerd Font로 바꿔 \e[0m \n"

	read -p "Nerd font 적용이 완료되었으면 Enter를 눌러 계속진행하기"
}

setup_dotfiles() {
	install_packages
	setup_symlink
	gen_secret
}

main() {
	echo -e "\e[1\e[30;47m Running coco's dotfiles setup...\e[0m\n"
	echo -e "  \e[1;96m (0) Setup Everything \e[0m"
	echo -e "  \e[1;96m (1) Setup Symlinks \e[0m"
	echo -e "  \e[1;96m (2) Install Packages \e[0m"
	echo -e "  \e[1;96m (3) Generate gpg & ssh secret \e[0m"
	echo -e "  \e[1;96m (4) Backup Configs \e[0m"
	echo -e "  \e[1;91m (*) Anything else to exit \e[0m\n"
	echo -en "\e[1m select options:  \e[0m"

	read -r option
	case $option in
	"0") echo setup_dotfiles ;;
	"1") echo setup_symlink ;;
	"2") echo install_packages ;;
	"3") echo gen_secret ;;
	"4") echo backup_configs ;;
	*) echo -e "\e[31;1m see you next time coco! 0ㅅ0 \e[0m" ;;
	esac
	exit 0
}

main
