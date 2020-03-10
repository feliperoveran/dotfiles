#!/bin/bash

install_libraries() {
  sudo apt-get update && sudo apt-get install -y software-properties-common \
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
    htop \
    python3-pip \
    xdotool \
    xclip \
    exuberant-ctags
}

install_docker(){
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

  sudo apt-get update && sudo apt-get install -y docker-ce

  sudo groupadd docker

  sudo usermod -aG docker $USER

  # activate the changes to the docker group
  newgrp docker
}

install_spotify() {
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
    0DF731E45CE24F27EEEB1450EFDC8610341D9410

  echo deb http://repository.spotify.com stable non-free |
    sudo tee /etc/apt/sources.list.d/spotify.list

  sudo apt-get update && sudo apt-get install spotify-client
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

install_libraries
# install_spotify
install_docker
install_solarized_theme
install_fzf
# pip3 install grip --user
