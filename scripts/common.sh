#!/usr/bin/env bash

set -ex

main() {
    apt-get update
    install_dev_tools
    clean_up
}

#
# Installs development tools.
#
install_dev_tools() {
    # Install packages available in apt-get
    apt-get install -y \
        git \
        tree \
        linux-kernel-headers \
        build-essential

    # Install go1.12.6
    wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
    sudo tar xzvf go1.12.6.linux-amd64.tar.gz -C /usr/local
    echo "PATH=${PATH}:/usr/local/go/bin" >> /home/vagrant/.bashrc
}

#
# Cleans up after provisioning is complete.
#
clean_up() {
    rm -rf *.tar.gz
}

main
