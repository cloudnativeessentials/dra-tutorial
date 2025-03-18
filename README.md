# Unlock the future of Kubernetes and accelerators (and all specialized hardware) with Dynamic Resource Allocation

## Overview

At the heart of the AI revolution are GPUs and the platform that provides access to them is  Kubernetes. Workloads historically access GPUs and other devices with the device plugin API but features are lacking. The new Dynamic Resource Allocation (DRA) feature helps maximize GPU utilization across workloads with additional features like the ability to control device sharing across Pods, use multiple GPU models per node, handle dynamic allocation of multi-instance GPU (MIG) and more. DRA is not limited to GPUs but any specialized hardware that a Pod may use including network attached resources such as edge devices like IP cameras.
DRA is a new way to request for resources like GPUs and gives the ability to precisely control how resources are shared between Pods. 
This tutorial introduces DRA, reviews the “behind-the-scenes” of DRA in the Kubernetes cluster and walks through multiple ways to use DRA to request for GPU and a network attached resource.


## Tutorial overview:
- DRA Resources
  - review the Kubernetes resources for Dynamic Resource Allocation 
- Installing a DRA driver
- Running a Pod accessing a GPU via DRA

