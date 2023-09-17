#!/bin/bash

POD_CIDR="172.15.0.0/16" # Provide the same value specified when deploying the Kubernetes cluster

# Check if POD_CIDR is empty, and if so, print an error and exit
if [ -z "$POD_CIDR" ]; then
    echo "Error: POD_CIDR value not provided."
    exit 1
fi

# Step 1: Install the operator
echo "Installing the Calico operator..."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

# Step 2: Download custom resources
echo "Downloading custom resources..."
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -o custom-resources.yaml

# Step 3: Update the custom-resources.yaml with the specified POD_CIDR value
echo "Updating custom-resources.yaml with POD_CIDR=$POD_CIDR"
sed -i "s|cidr:.*|cidr: $POD_CIDR|" custom-resources.yaml

# Step 4: Create the manifest to install Calico
echo "Creating the manifest to install Calico..."
kubectl create -f custom-resources.yaml

# Step 5: Print message for manual verification
echo ""
echo "Calico installation initiated. You can manually check Calico installation by running:"
echo "kubectl get pods -n calico-system"

