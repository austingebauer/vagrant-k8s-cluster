#!/usr/bin/env bash

set -ex

main() {
    apt-get update
    install_tools
    install_docker
    install_k8s
    clean_up
}

install_tools() {
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        gnupg-agent \
        jq
}

install_docker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update && apt-get install -y \
      containerd.io=1.2.10-3 \
      docker-ce=5:19.03.4~3-0~ubuntu-"$(lsb_release -cs)" \
      docker-ce-cli=5:19.03.4~3-0~ubuntu-"$(lsb_release -cs)"

    cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

    mkdir -p /etc/systemd/system/docker.service.d
    sudo usermod -aG docker vagrant
    systemctl daemon-reload
    systemctl restart docker
}

install_k8s() {
    # disable swap
    swapoff -a
    sed -i '/swap/d' /etc/fstab

    # install kubeadm, kubelet and kubectl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    # pull images
    kubeadm config images pull &
}

clean_up() {
    rm -rf ./*.tar.gz
}

main
