#!/bin/bash

# 1. package install
# 2. yay , yay package
# 3. stow linking
# 3. zsh setting
# 4. gen ssh gpg

declare -a common_packages=(
  git lazygit zsh curl wget fzf fd ripgrep tree xclip ca-certificates gnupg less python python3 htop nodejs-lts-iron npm
  neofetch openssh rsync avahi reflector trash-cli clang cmake zip unzip docker docker-compose lua lua51 luarocks stow zoxide
)

install_common_packages() {
  sudo pacman -S --needed "${common_packages[@]}"
}

# yay
declare -a yay_packages=(
  oh-my-posh
)

install_yay() {
  sudo pacman -S --needed git base-devel
  cd ~
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  cd ~
  rm -fr yay
}

declare -a yay_packages=(
  oh-my-posh
)

install_yay_packages() {
  sudo yay -S --needed "${yay_packages[@]}"
}

declare -a prev_conf=(
  ".bashrc" ".bash_profile" ".bash_logout" ".bash_history"
)

delete_prev_conf() {
  for file in "${prev_conf[@]}"; do
    rm "~/$file"
  done
}

install_packages() {
  install_common_packages
  install_yay
  install_yay_packages
}

setup_symlink() {
  delete_prev_conf
  cd ~/dotfiles/config
  stow -t $HOME .
}

# generate ssh for github
# clone한 repo가 push되지않는다면 등록된 원격 rpeo를 삭제후 다시 등록하세요.
# https://docs.github.com/ko/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
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
  gpg --full-generate-key # RSA & RSA / 4096 / no expire / cocozzang / cocozz503@naver.com
  gpg --list-secret-keys --keyid-format=long
  # sec   4096R/3AA5C34371567BD2 2016-03-10 [expires: 2017-03-10] 에서 3AA5C34371567BD2 부분이 key입니다
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
  echo -e "\e[2;30;103m \e[4mhttps://www.nerdfonts.com/font-downloads\e[24m 에서 CaskaydiaCove Nerd Font를 다운받고 \e[0m
\e[2;30;103m window terminal emulator내의 Arch profile font를 CaskaydiaCove Nerd Font를 로 바꿔 \e[0m \n"

  read -p "Nerd font 적용이 완료되었으면 Enter를 눌러 계속진행하기"
  sudo usermod -aG docker $USER
  cd ~
  chsh $USER
  /bin/zsh
}

setup_dotfiles() {
  install_packages
  setup_symlink
  gen_secret
  nerd_font_info
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
  "0") setup_dotfiles ;;
  "1") setup_symlink ;;
  "2") install_packages ;;
  "3") gen_secret ;;
  "4") backup_configs ;;
  *) echo -e "\e[31;1m see you next time coco! 0ㅅ0 \e[0m" ;;
  esac
  exit 0
}

main
