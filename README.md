# Kubernetes Training Repository (k8s-training)

This repository contains a variety of resources and scripts for training purposes with Kubernetes (k8s). It is structured to facilitate hands-on learning experiences across different Kubernetes features and components. This includes network plugins, cluster installation procedures, and exploration of different service types in Kubernetes.

## Repository Structure Overview

### 1. k8s-installation
Here, you'll find scripts and resources specifically for the installation of Kubernetes clusters. This includes automated installation scripts using tools like `kubeadm`, and additional resources for updating or maintaining Kubernetes clusters.

### 2. cni-calico
This directory focuses on the Calico Container Network Interface (CNI) plugin for Kubernetes. It includes resources for installing Calico, along with documentation and test descriptors for verifying network functionality and connectivity within a Kubernetes cluster using Calico.

### 3. services
The `services` directory provides resources to understand and implement various Kubernetes Service types. It covers aspects like ClusterIP, NodePort, and load balancing within Kubernetes, offering practical examples and configurations.

---

## Best practices

Utilizing efficient tools and practices can significantly streamline your workflow. Here are some recommended practices and tools:

### Useful Tools
1. **kubectx and kubens (specially for managing multiple Kubernetes clusters/context):** 
   - `kubectx` simplifies switching between Kubernetes contexts. 
   - `kubens` assists in switching between Kubernetes namespaces.
   - These tools enhance the ease of managing multiple clusters and namespaces.

2. **k9s:**
   - `k9s` provides a terminal UI to interact with your Kubernetes clusters, offering an efficient way to navigate and observe Kubernetes resources.

### Generating a Joint `kubeconfig` File
- To work with tools like `kubectx`, you might need a single `kubeconfig` file that contains information for multiple clusters.
- You can merge multiple `kubeconfig` files into a single file using the following commands:

   ```bash
   # Merge ~/.kube/config-cluster-1 and ~/.kube/config-cluster-2 into new config /tmp/config
   KUBECONFIG=~/.kube/config-cluster-1:~/.kube/config-cluster-2 kubectl config view --flatten > /tmp/config

   # Replace old config with new merged config
   mv /tmp/config ~/.kube/config
   ```

### Additional Tips
- **Context Naming Conventions:** Use clear and consistent naming for your contexts to avoid confusion.
- **Security:** Regularly update access permissions and consider using more secure authentication methods.
- **Backup and Version Control:** Keep backups of your `kubeconfig` files and consider using version control to track changes.
- **Environment Separation:** For high-security environments like production, consider maintaining separate `kubeconfig` files to reduce the risk of accidental changes.
