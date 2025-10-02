# Unlock the future of Kubernetes and accelerators with Dynamic Resource Allocation (DRA)

At the heart of the AI revolution are GPUs and the platform that provides access to them is Kubernetes. 
Workloads historically access GPUs and other devices with the device plugin API but features are lacking. 
The new Dynamic Resource Allocation (DRA) feature helps maximize GPU utilization across workloads with 
additional features like the ability to control device sharing across Pods, use multiple GPU models per node, 
handle dynamic allocation of multi-instance GPU (MIG) and more. DRA is not limited to GPUs but any specialized 
hardware that a Pod may use including network attached resources such as edge devices like IP cameras.
DRA is a new way to request for resources like GPUs and gives the ability to precisely control how resources are shared between Pods.
This tutorial introduces DRA, reviews the “behind-the-scenes” of DRA in the Kubernetes cluster and walks through multiple ways to use DRA to request for GPU and a network attached resource. 


Kubernetes 1.34 was released in August and the core components of DRA was GA’d 


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
