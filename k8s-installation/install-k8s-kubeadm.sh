#!/bin/bash
#####################################################################################
# Script to install Kubernetes via kubeadm using containerd as the container runtime.
#####################################################################################

##################
# START OF VARIABLES
K8S_VERSION=1.28.2-1.1
MASTER_NODE_IP=172.28.5.188
POD_CIDR=172.15.0.0/16
# END OF VARIABLES
##################

# Check if any variable is missing
if [ -z "$K8S_VERSION" ] || [ -z "$MASTER_NODE_IP" ] || [ -z "$POD_CIDR" ]; then
    echo "Error: One or more variables are missing. Please set all variables."
    exit 1
fi

# Differenciate between Master and Worker node.
while true; do
    read -p "Is this a master node? (y or n): " yn
    case $yn in
        [Yy]* ) IS_MASTER=true; break;;
        [Nn]* ) IS_MASTER=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

###############################
# CRI Installation: Containerd
###############################
# Load overlay & br_netfilter modules
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Configure systctl to persist
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl parameters
sudo sysctl --system

# Install containerd
# sudo apt-get update && sudo apt-get install -y containerd=1.3.3
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update
sudo apt install containerd.io

# Set the cgroup driver for runc to systemd
# Create the containerd configuration file (containerd by default takes the config looking
# at /etc/containerd/config.toml)
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/' /etc/containerd/config.toml
# sudo rm /etc/containerd/config.toml

# Restart containerd with the new configuration
sudo systemctl restart containerd

# disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

###############################
# Kubernetes installation
###############################
# Update the apt package index and install packages needed to use the Kubernetes apt repository
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# Check which versions are available
# apt-cache madison kubelet kubeadm kubectl

# Download public signing key for the Kubernetes package repository
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# install kubelet, kubeadm and kubectl, and pin their version
sudo apt-get update
sudo apt-get install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION
sudo apt-mark hold kubelet kubeadm kubectl

if $IS_MASTER; then
    #--pod-network-cidr=$POD_CIDR
    sudo kubeadm init --apiserver-advertise-address=$MASTER_NODE_IP --pod-network-cidr=$POD_CID
    # Once kubeadm has bootstraped the K8s cluster, set proper access to the cluster from the CP/master node
    mkdir -p "$HOME"/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Untaint master nodes
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
else
    echo "Do no forget to join the worker to the cluster!"
fi
