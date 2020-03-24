# vagrant-k8s-cluster

Provisions a 3 node Kubernetes cluster in VirtualBox or VMWare Fusion using Vagrant.

## Prerequisites

The following software must be installed before use:
- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/) or [VMWare Fusion](https://www.vmware.com/products/fusion.html)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Usage

### Cluster Turnup

```
vagrant up --provider virtualbox
```

```
vagrant up --provider vmware_desktop
```

### Kubectl

#### Local Machine

A kubeconfig file name `config` will be written to the vagrant-k8s-cluster root 
directory after cluster turnup is complete.

In order to use the `kubectl` from your local machine to talk to the kubernetes 
API server, export the following environment variable:

```
export KUBECONFIG=$KUBECONFIG:<path>/<to>/vagrant-k8s-cluster/config
```

#### Master and Worker nodes

Kubectl is configured for use on both master and worker nodes after cluster turnup is
complete. Use `vagrant ssh` to get SSH remote access to one of the nodes in the cluster.
