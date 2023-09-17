#!/bin/bash

# Step 1: Install the operator
echo "Installing the Calico operator..."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

# Extract the podSubnet value from kubeadm-config ConfigMap
POD_CIDR=$(kubectl get cm -o json -n kube-system kubeadm-config | grep -oP '(?<=podSubnet: ).*')

# Step 2: Download custom resources
echo "Downloading custom resources..."
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -o custom-resources.yaml

# Update the custom-resources.yaml with the extracted podSubnet value
echo "Updating custom-resources.yaml with POD_CIDR=$POD_CIDR"
sed -i "s|cidr:.*|cidr: $POD_CIDR|" custom-resources.yaml

# Step 4: Create the manifest to install Calico
echo "Creating the manifest to install Calico..."
# kubectl create -f custom-resources.yaml

# Step 5: Verify Calico installation
echo "Verifying Calico installation..."
# watch kubectl get pods -n calico-system

