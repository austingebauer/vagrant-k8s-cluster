#!/usr/bin/env bash

set -ex

main() {
    sudo /vagrant/join.sh
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    echo "export KUBECONFIG=/vagrant/config" >> .bashrc
}

main
