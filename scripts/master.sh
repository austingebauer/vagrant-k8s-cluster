#!/usr/bin/env bash

set -x

main() {
    init_master
    kubectl_nonroot_user
    deploy_cni_pod_network

    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    wait_dns_running

    # enable running kubectl from worker nodes
    sudo cp /etc/kubernetes/admin.conf /vagrant
}

init_master() {
    JOIN_WORKER_SCRIPT=/vagrant/join.sh
    rm -rf JOIN_WORKER_SCRIPT
    sudo kubeadm init \
        --apiserver-advertise-address=10.0.1.10 \
        --pod-network-cidr=192.168.0.0/16 | tee "${HOME}"/init-output.txt

    grep -A 2 "kubeadm join" "${HOME}"/init-output.txt > "${JOIN_WORKER_SCRIPT}"
    cat "${JOIN_WORKER_SCRIPT}"
    chmod +x "${JOIN_WORKER_SCRIPT}"
}

kubectl_nonroot_user() {
    mkdir -p "$HOME"/.kube
    sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
    sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
}

deploy_cni_pod_network() {
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
}

wait_dns_running() {
    for i in {1..10}
    do
        echo "$i"
        kubectl get pods --all-namespaces
        sleep 5s
    done
}

main
