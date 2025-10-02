# Unlock the future of Kubernetes and accelerators with Dynamic Resource Allocation (DRA)

At the heart of the AI revolution are GPUs and the platform that provides access to them is Kubernetes. 
Workloads historically access GPUs and other devices with the device plugin API but features are lacking. 
The new Dynamic Resource Allocation (DRA) feature helps maximize GPU utilization across workloads with additional features like the ability to control device sharing across Pods, use multiple GPU models per node, handle dynamic allocation of multi-instance GPU (MIG) and more. DRA is not limited to GPUs but any specialized hardware that a Pod may use including network attached resources such as edge devices like IP cameras.
DRA is a new way to request for resources like GPUs and gives the ability to precisely control how resources are shared between Pods.
This tutorial introduces DRA, reviews the “behind-the-scenes” of DRA in the Kubernetes cluster and walks through multiple ways to use DRA to request for GPU and a network attached resource. 

In this tutorial we will install a Kubernetes cluster, review the DRA resources and how they work, install a sample DRA driver, run workloads that use the DRA driver.

## Module 1: Introduction to Dynamic Resource Allocation (DRA)
Kubernetes 1.34 was released in August and the core components of DRA were promoted to stable / GA.
Workloads need more than CPU and memory but also need specialized hardware.
DRA is a new API for Pods to request and access specialized hardware like accelerators or network-attached devices.
Support for hardware are provided by vendors via DRA drivers.

The previous way of accessing specialized hardware was with node plugins and had limitations such as the inability to share allocated devices among multiple Pods and the device had to be attached to a node (node-local) not across the network fabric.

Node plugins are good for requesting single, linear quantity of resources.


## Cluster setup

Since DRA was GA'd in Kubernetes v1.34 released in August of 2025. You will use kind (Kubernetes in Docker) in this lab.

Log into your VM
```shell
```

There is a script that will install kind cluster with 1 control plane and 1 worker node cluster.

Run the install script:
```shell
curl https://raw.githubusercontent.com/cloudnativeessentials/dra-tutorial/refs/heads/main/install-kind-cilium.sh | sh
```

Output:

```shell
kind cluster is ready
```

Let's test the cluster
```shell
kubectl version
```

Output:
```shell
```

```shell
kubectl get nodes
```

Output:
```shell
```


Module 1
5 minutes - What is DRA
Motivation
Benefits
5 minutes - Cluster setup (kind on RHEL)

Module 2
5 minutes - Difference between DRA and Device Plugin
5 minutes - Explain why the change

Module 3
5 minutes - Explain DRA under the covers
5 minutes - Explore DRA Resources

Module 4
5 minutes - Explore Workload YAML that uses DRA
5 minutes - Run Workload YAML that uses DRA
5 minutes - Confirm DRA uses

Module 5
5 minutes - Review benefits of DRA
5 minutes - Explore YAML on how to use the different benefits of DRA
Building a DRA driver?
GPU examples?
Look at Intel and NVIDIA?
