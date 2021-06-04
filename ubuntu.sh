#!/bin/bash

install_libraries() {
  sudo apt-get update && sudo apt-get install -y software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnome-tweak-tool \
    silversearcher-ag \
    tmux \
    dconf-cli \
    vim \
    htop \
    python3-pip \
    xdotool \
    xclip \
    exuberant-ctags \
    meld \
    pwgen \
    jq
}

install_docker(){
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

  sudo apt-get update && sudo apt-get install -y docker-ce

  sudo groupadd docker || true

  sudo usermod -aG docker $USER || true

  # activate the changes to the docker group
  newgrp docker
}

install_kubectl(){
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

  chmod +x ./kubectl

  sudo mv ./kubectl /usr/local/bin/kubectl

  echo "# enable kubectl bash completion" >> ~/.bashrc
  echo "source <(kubectl completion bash)" >> ~/.bashrc
}

install_minikube(){
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo chmod +x minikube

  sudo mkdir -p /usr/local/bin/

  sudo mv minikube /usr/local/bin/minikube
}

install_solarized_theme() {
  git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git

  ./gnome-terminal-colors-solarized/install.sh \
    --install-dircolors \
    --scheme dark_alternative
}

# Install fuzzy finder https://github.com/junegunn/fzf
install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

  ~/.fzf/install --all
}

install_vim_plugins() {
  # install vim plug
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  vim -N "+set hidden" "+syntax on" +PlugInstall +qall
}

install_tmux_plugins(){
  git clone https://github.com/tmux-plugins/tpm ./tmux/plugins/tpm

  ~/.tmux/plugins/tpm/bin/install_plugins
}

remap_capslock(){
  gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier', 'altwin:meta_alt']"
}

install_libraries
install_solarized_theme
install_tmux_plugins
install_vim_plugins
install_fzf
# install_kubectl
# install_docker
# install_minikube
pip3 install grip --user
