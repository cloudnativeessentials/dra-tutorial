# Unlock the future of Kubernetes and accelerators with Dynamic Resource Allocation (DRA)

At the heart of the AI revolution are GPUs and the platform that provides access to them is Kubernetes. 
Workloads historically access GPUs and other devices with the device plugin API but features are lacking. 
The new Dynamic Resource Allocation (DRA) feature helps maximize GPU utilization across workloads with additional features like the ability to control device sharing across Pods, use multiple GPU models per node, handle dynamic allocation of multi-instance GPU (MIG) and more. DRA is not limited to GPUs but any specialized hardware that a Pod may use including network attached resources such as edge devices like IP cameras.
DRA is a new way to request for resources like GPUs and gives the ability to precisely control how resources are shared between Pods.
This tutorial introduces DRA, reviews the “behind-the-scenes” of DRA in the Kubernetes cluster and walks through multiple ways to use DRA to request for GPU and a network attached resource. 

In this tutorial we will install a Kubernetes cluster, review the DRA resources and how they work, install a sample DRA driver, run workloads that use the DRA driver.

# Old way
Node Feature Discovery
GPU Feature Discovery
Device Plugin
Container Toolkit (on the host), shim on top of containerd or docker on top of runc, to handle GPU integration with device driver
CUDA 
Device Driver (from vendor e.g. AMD, NVIDIA, on the host)

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
This script installs Docker, kind, kubectl, and creates a kind cluster
This will take several minutes to complete
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
sysctl fs.inotify.max_user_watches=524288
sysctl fs.inotify.max_user_instances=512
Installing docker
Updating Subscription Management repositories.
Unable to read consumer identity
...
Cluster Pods:          3/3 managed by Cilium
Helm chart version:    1.18.0
Image versions         cilium             quay.io/cilium/cilium:v1.18.0@sha256:dfea023972d06ec183cfa3c9e7809716f85daaff042e573ef366e9ec6a0c0ab2: 2
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.34.4-1753677767-266d5a01d1d55bd1d60148f991b98dac0390d363@sha256:231b5bd9682dfc648ae97f33dcdc5225c5a526194dda08124f5eded833bf02bf: 2
                       cilium-operator    quay.io/cilium/operator-generic:v1.18.0@sha256:398378b4507b6e9db22be2f4455d8f8e509b189470061b0f813f0fabaf944f51: 1
kind cluster is ready
```

Let's test the cluster
```shell
kubectl version
```

Output:
```shell
Client Version: v1.34.1
Kustomize Version: v5.7.1
Server Version: v1.34.0
```
DRA became stable in v1.34, previous versions require enabling DRA.

Check the cluster's nodes:
```shell
kubectl get nodes
```

Output:
```shell
NAME                 STATUS   ROLES           AGE     VERSION
kind-control-plane   Ready    control-plane   2m27s   v1.34.0
kind-worker          Ready    <none>          2m14s   v1.34.0
```

Before we look at the DRA resources, let's take a look at a generic DRA Resource Driver

## DRA Resource Driver
2 components that coordinate with each other
- node-local kubelet plugin (DaemonSet) on nodes with the advertised device
- centralized controller runing in HA

Centralized Controller
- coordinates with Kubernetes scheduler to decide which node a ResourceClaim can be serviced on
- performs the actual Resource Claim allocation after a node is selected by the scheduler
- performs deallocation of ResourceClaim once deleted

Node-local kubelet plugin
- advetise node-local state that the centralize controller needs to help make allocation decisions
- makes node-local operations required to prepare a ReourceClaim (parameters may need to be setup) or deallocate a ResourceClaim on a node
- pass the device associated with prepared ResourceClaim to the kubelet which will then forward to the container runtime

2 Modes to communicate between Centralized Controller and kubelet-plugin
- Single, all-purpose, per-node CRD
  - kubelet plugin advertises available resources
  - Controller tracks resources allocated
  - kubelet-plugin tracks resources it prepared
- Split-purpose Communication
  - kubelet plugin advertises available resources via CRD that the controller can access
  - Controller tracks allocated resources through ResourceHandle in ResourceClaim
  - kubelet-plugin tracks resources in a checkpoint file on the local filesystem
 
Modes of Allocating Resources with DRA (specified in the ResourceClaim)
- Immediate
  - More restrictive, resource availability is not considered
  - Allocate resources immediately upon the creation of ResourceClaim
  - Pods are restricted to those nodes with ResourceClaim (other resource availability is not considered in scheduling)
- Delayed (wait for first consumer)
  - Resource availability is considered in part of overall Pod scheduling
  - Delays the allocation of the ResourceClaim until the first Pod that references it is scheduled

## ResourceSlice
Represents the devices on the node.
  

## DeviceClass

The DeviceClass resource correspondes a resource driver with a named resource in the cluster.
Contains pre-defined selection criteria for certain devices and configuration for them.
Can include optional parameters like a GPUClaimParameters that we'll look at later.

Each request to allocate a device in a ResourceClaim must reference exactly one DeviceClass.
A DeviceClas defines a category of devices.
The DeviceClass may be installed with the driver.

```shell
kubectl explain deviceclass
```

Output:
```shell
GROUP:      resource.k8s.io
KIND:       DeviceClass
VERSION:    v1

DESCRIPTION:
    DeviceClass is a vendor- or admin-provided resource that contains device
    configuration and selectors. It can be referenced in the device requests of
    a claim to apply these presets. Cluster scoped.
    
    This is an alpha type and requires enabling the DynamicResourceAllocation
    feature gate.
    
FIELDS:
  apiVersion	<string>
    APIVersion defines the versioned schema of this representation of an object.
    Servers should convert recognized schemas to the latest internal value, and
    may reject unrecognized values. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources

  kind	<string>
    Kind is a string value representing the REST resource this object
    represents. Servers may infer this from the endpoint the client submits
    requests to. Cannot be updated. In CamelCase. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds

  metadata	<ObjectMeta>
    Standard object metadata

  spec	<DeviceClassSpec> -required-
    Spec defines what can be allocated and how to configure it.
    
    This is mutable. Consumers have to be prepared for classes changing at any
    time, either because they get updated or replaced. Claim allocations are
    done once based on whatever was set in classes at the time of allocation.
    
    Changing the spec automatically increments the metadata.generation number.
```

A DeviceClass template is:
```yaml
apiversion: resource.k8s.io/v1alpha3
kind: DeviceClass
metadata:
  name: gpu.vendor.com
spec:
  selectors:
  - cel:
      expression: "device.driver == 'gpu.vendor.com'"
```

## ResourceClaim
Describes a request for access to resources in the cluster, for use by workloads. 
For example, if a workload needs an accelerator device with specific properties, this is how that request is expressed. 
The `status` stanza tracks whether this claim has been satisfied and what specific resources have been allocated.
A ResourceClaim is a claim to use a specific DeviceClass and represents an acual resource allocation made by the resource driver.
Users create ResourceClaims and reger to the DeviceClass they want to allocate resources for. The Pod can then use these resources with a ResourceClaim.

```shell
kubectl explain resourceclaim
```

Output:
```shell
GROUP:      resource.k8s.io
KIND:       ResourceClaim
VERSION:    v1

DESCRIPTION:
    ResourceClaim describes a request for access to resources in the cluster,
    for use by workloads. For example, if a workload needs an accelerator device
    with specific properties, this is how that request is expressed. The status
    stanza tracks whether this claim has been satisfied and what specific
    resources have been allocated.
    
    This is an alpha type and requires enabling the DynamicResourceAllocation
    feature gate.
    
FIELDS:
  apiVersion	<string>
    APIVersion defines the versioned schema of this representation of an object.
    Servers should convert recognized schemas to the latest internal value, and
    may reject unrecognized values. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources

  kind	<string>
    Kind is a string value representing the REST resource this object
    represents. Servers may infer this from the endpoint the client submits
    requests to. Cannot be updated. In CamelCase. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds

  metadata	<ObjectMeta>
    Standard object metadata

  spec	<ResourceClaimSpec> -required-
    Spec describes what is being requested and how to configure it. The spec is
    immutable.

  status	<ResourceClaimStatus>
    Status describes whether the claim is ready to use and what has been
    allocated.
```


ResourceClaims can be created manually by users or by Kubernetes from a ResourceClaimTemplate.
If a ResourceClaimTemplate is used then the ResourceClaim is tied to a specific Pod and tied to the Pod's lifecycle.
If a ResourceClaim is to be shared among multiple Pods or if the ResourceClaim is to be independent of a Pod's lifecycle then manually create the Resource Claim.

Sample ResourceClaim:
```yaml
apiVersion: resource.k8s.io/v1
kind: ResourceClaim
metadata:
  name: shared-gpu-resourceclaim
spec:
  devices:
    requests:
    - name: single-gpu-claim
      exactly:
        deviceClassName: gpu.vendor.com
        allocationMode: All
        selectors:
        - cel:
            expression: |-
              device.attributes["driver.example.com"].type == "gpu" &&
              device.capacity["driver.example.com"].memory == quantity("64Gi")             
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
