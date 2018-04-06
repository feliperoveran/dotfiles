#!/bin/bash

install_libraries() {
  sudo apt-get install -y python-software-properties \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    unity-tweak-tool \
    gnome-tweak-tool \
    silversearcher-ag \
    tmux \
    dconf-cli \
    vim-gnome \
    docker-ce \
    spotify-client
}

add_docker_key() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
}

add_docker_repository() {
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
}

fix_docker_permissions() {
  sudo groupadd docker

  sudo usermod -aG docker $USER
}

add_rvm_key_and_repo() {
  gpg --keyserver hkp://keys.gnupg.net --recv-keys \
    409B6B1796C275462A1703113804BB82D39DC0E3

  curl -sSL https://get.rvm.io | bash -s stable

  sudo add-apt-repository -y ppa:pi-rho/dev
}

add_spotify_key_and_repo() {
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
    0DF731E45CE24F27EEEB1450EFDC8610341D9410

  echo deb http://repository.spotify.com stable non-free |
    sudo tee /etc/apt/sources.list.d/spotify.list
}

install_solarized_theme() {
  git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
  ./gnome-terminal-colors-solarized/install.sh

  git clone https://github.com/tmux-plugins/tpm ./tmux/plugins/tpm
}

# Install fuzzy finder https://github.com/junegunn/fzf
install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

  ~/.fzf/install
}

add_rvm_key_and_repo
add_spotify_key_and_repo
add_docker_key
add_docker_repository
sudo apt-get update
install_libraries
install_solarized_theme
install_fzf
fix_docker_permissions
