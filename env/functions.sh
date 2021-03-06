#!/bin/bash

# Provide functions for provisioning

RED="0;31"
GREEN="0;32"
BLUE="0;34"

# Output a string with a colour
# $1 - colour
# $2 - string
output () {
    echo -e "\033[$1m[PROVISIONER] $2\033[0m"
}

# Update the box - common functionality
box_update () {
    output $BLUE "Updating apt-get sources..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get -qq -y update
    apt-get -qq -y upgrade
}

# Make sure the box stores a hidden file to say when it was installed
box_register () {
    echo 'Box provisioned - `date`' > /home/vagrant/.provisioned
}

# Install ZSH
box_install_zsh() {
    output $BLUE "Installing ZSH and oh-my-zsh..."
    apt-get -qq -y install curl git zsh
    chsh -s /bin/zsh vagrant
    curl -s -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
    sed -i 's/robbyrussell/agnoster/' /root/.zshrc
    sed -i 's/git/git git-flow gnu-utils phing screen/' /root/.zshrc
    cp /root/.zshrc /home/vagrant/
    cp -R /root/.oh-my-zsh /home/vagrant/
    chown vagrant /home/vagrant/.zshrc
    chown vagrant /home/vagrant/.oh-my-zsh
    output $GREEN "ZSH installed."
}