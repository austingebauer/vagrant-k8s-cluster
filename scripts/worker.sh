#!/usr/bin/env bash

set -x

main() {
    sudo /vagrant/join.sh
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
}

main
