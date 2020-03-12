#!/usr/bin/env bash

set -ex

main() {
    init_master
    kubectl_nonroot_user
    deploy_cni_pod_network

    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    wait_until_pods_ready 120 1

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

function is_pod_ready() {
  [[ "$(kubectl get po --namespace=kube-system "$1" \
  -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}')" == 'True' ]]
}

function pods_ready() {
  local pod

  [[ "$#" == 0 ]] && return 0

  for pod in $pods; do
    is_pod_ready "$pod" || return 1
  done

  return 0
}

function wait_until_pods_ready() {
  local period interval i pods

  if [[ $# != 2 ]]; then
    echo "Usage: wait_until_pods_ready PERIOD INTERVAL" >&2
    echo "" >&2
    echo "This script waits for all pods to be ready in the current namespace." >&2

    return 1
  fi

  period="$1"
  interval="$2"

  for ((i=0; i<$period; i+=$interval)); do
    pods="$(kubectl get po --namespace=kube-system -o 'jsonpath={.items[*].metadata.name}')"
    if pods_ready $pods; then
      return 0
    fi

    sleep "$interval"
    echo "Waiting for pods to be ready: $i seconds elapsed"
  done

  echo "Waited for $period seconds, but all pods are not ready yet."
  kubectl get po --namespace=kube-system
  return 1
}

main
