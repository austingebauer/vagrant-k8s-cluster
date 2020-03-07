#!/usr/bin/env bash

set -x

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
    echo "START: disable swap"
    swapoff -a
    sed -i '/swap/d' /etc/fstab
    echo "END"

    echo "START: pull images"
    kubeadm config images pull &
    echo "END"

    echo "START: ensure iptables tooling does not use the nftables backend"
    sudo apt-get install -y iptables arptables ebtables
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
    sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
    sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy
    echo "END"

    echo "START: install kubeadm, kubelet and kubectl"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    echo "END"
}

clean_up() {
    rm -rf ./*.tar.gz
}

main
