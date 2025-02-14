# High Availability Kubernetes Cluster with Kubeadm

## Overview
Set up a highly available Kubernetes cluster deployed using **Terraform**, **Ansible**, and **Kubeadm**. The cluster is configured with multiple control plane nodes, an AWS Network Load Balancer for API server redundancy, **Containerd** as the container runtime, **Cilium** as the CNI for high-performance networking, and **CoreDNS** for service discovery. Additionally, the AWS Cloud Controller Manager is installed to enable cloud-native resource management, and **Longhorn** is used as a storage backend for persistent volumes.

## Cluster Deployment Architecture

### 1. **Infrastructure Provisioning**
- **Terraform** is used to provision Kubernetes master and worker nodes on AWS.
- Each control plane node is assigned a public and private IP.
- AWS Network Load Balancer (NLB) is created to distribute traffic to control plane nodes.

### 2. **Kubernetes Cluster Initialization**
- **Ansible** is used to configure master and worker nodes.
- **Kubeadm** is utilized to initialize and manage the cluster.
- The cluster is configured for high availability (HA) with multiple control plane nodes.
- Worker nodes communicate with the API server through the AWS NLB.

### 3. **Load Balancer Configuration**
- An AWS **Network Load Balancer (NLB)** is created to forward traffic from worker nodes to the control plane API server.
- The load balancer distributes traffic to all healthy control plane nodes.
- **Health check** is performed via a TCP check on port `6443` (default API server port).
- The NLB must always match the address specified in `kubeadm`'s `ControlPlaneEndpoint`.
- The load balancer ensures that requests to the API server are evenly distributed.

### 4. **Container Runtime**
- **Containerd** is installed as the container runtime on all nodes.

### 5. **Networking**
- **Cilium** is deployed as the CNI to enable high-performance cloud-native networking with eBPF.

### 6. **DNS Management**
- **CoreDNS** is installed on the control plane nodes for internal DNS resolution.

### 7. **AWS Cloud Integration**
- **AWS Cloud Controller Manager (CCM)** is installed to enable integration with AWS services.
- Services are exposed through the AWS Network Load Balancer.

### 8. **Persistent Storage**
- **Longhorn** is deployed as a distributed block storage solution for managing persistent volumes.

## Cluster Architecture 
![kubeadm-new-2](https://github.com/user-attachments/assets/0dbdeb8e-ee8c-416a-b8cf-1e9c6b3155f0)

## Kubernetes Cluster SetUp

## Overview
This project automates the deployment of a Kubernetes cluster on AWS using Terraform and Ansible. It sets up:
- **Two Master Nodes** (EC2 instances)
- **Three Worker Nodes** (EC2 instances)
- **A Network Load Balancer (NLB)** for API server traffic routing
- **Ansible Playbook** for Kubernetes cluster configuration

## Prerequisites
Ensure you have the following installed on your local machine:
- Terraform (>= 1.0.0)
- Ansible (>= 2.10)
- AWS CLI (configured with necessary IAM permissions)

## Deployment Steps

### 1. Clone the Repository
```bash
git clone https://github.com/dilafar/kubernetes-cluster.git
cd kubernetes-cluster
```

### 2. Deploy Infrastructure with Terraform
Navigate to the Terraform directory:
```bash
cd terraform
```
Initialize Terraform:
```bash
terraform init
```
Validate the Terraform configuration:
```bash
terraform validate
```
Generate and review the execution plan:
```bash
terraform plan
```
Apply Terraform to create resources:
```bash
terraform apply -auto-approve
```

### 3. Configure Kubernetes Cluster with Ansible
After Terraform successfully provisions the infrastructure, navigate to the Ansible directory:
```bash
cd ansible
```
Run the Ansible playbook:
```bash
ansible-playbook k8s-cluster.yaml
```

## Verification
Once the setup is complete, verify the Kubernetes cluster:
```bash
kubectl get nodes
```



