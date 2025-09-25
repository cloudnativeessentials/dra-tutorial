# DRA Resources

Before we use Dynamic Resoure Allocation (DRA) you must understand the Kubernetes resources of DRA.

DRA is an API to request and share devices (e.g. GPUs) of containers in Pods.

The concept is very similar to how Persistent Volumes are "claimed".

## DeviceClass

The DeviceClass is the representation of a device in Kubernetes.
Similar to a StorageClass.
When a devices is requested, a DeviceClass is referenced.

Let's take a look at DeviceClass:

```
kubectl explain deviceclass
```

Expected output:

```
GROUP:      resource.k8s.io
KIND:       DeviceClass
VERSION:    v1beta1

DESCRIPTION:
    DeviceClass is a vendor- or admin-provided resource that contains device
    configuration and selectors. It can be referenced in the device requests of
    a claim to apply these presets. Cluster scoped.
    
    This is an alpha type and requires enabling the DynamicResourceAllocation
    feature gate.

...
```

```
kubectl explain deviceclass.spec
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       DeviceClass
VERSION:    v1beta1

FIELD: spec <DeviceClassSpec>


DESCRIPTION:
    Spec defines what can be allocated and how to configure it.
    
    This is mutable. Consumers have to be prepared for classes changing at any
    time, either because they get updated or replaced. Claim allocations are
    done once based on whatever was set in classes at the time of allocation.
    
    Changing the spec automatically increments the metadata.generation number.
    DeviceClassSpec is used in a [DeviceClass] to define what can be allocated
    and how to configure it.
```

```
kubectl get deviceclass
```

Expected output:
```
NAME              AGE
gpu.example.com   110s
```

```
kubectl get deviceclass gpu.example.com -o yaml
```

Expected output:
```
apiVersion: resource.k8s.io/v1beta1
kind: DeviceClass
metadata:
  annotations:
    meta.helm.sh/release-name: dra-example-driver
    meta.helm.sh/release-namespace: dra-example-driver
  creationTimestamp: "2025-03-18T20:46:49Z"
  generation: 1
  labels:
    app.kubernetes.io/managed-by: Helm
  name: gpu.example.com
  resourceVersion: "916"
  uid: 4efefb71-24e5-44c3-b42a-259908802f03
spec:
  selectors:
  - cel:
      expression: device.driver == 'gpu.example.com'
root@rhel:~/dra-example-driver# 
```

## ResourceClaim

```
kubectl explain resourceclaim
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceClaim
VERSION:    v1beta1

DESCRIPTION:
    ResourceClaim describes a request for access to resources in the cluster,
    for use by workloads. For example, if a workload needs an accelerator device
    with specific properties, this is how that request is expressed. The status
    stanza tracks whether this claim has been satisfied and what specific
    resources have been allocated.
    
    This is an alpha type and requires enabling the DynamicResourceAllocation
    feature gate.

...
```

```
kubectl explain resourceclaim.spec
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceClaim
VERSION:    v1beta1

FIELD: spec <ResourceClaimSpec>


DESCRIPTION:
    Spec describes what is being requested and how to configure it. The spec is
    immutable.
    ResourceClaimSpec defines what is being requested in a ResourceClaim and how
    to configure it.
```

## ResourceClaimTemplate

```
kubectl explain resourceclaimtemplate
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceClaimTemplate
VERSION:    v1beta1

DESCRIPTION:
    ResourceClaimTemplate is used to produce ResourceClaim objects.
    
    This is an alpha type and requires enabling the DynamicResourceAllocation
    feature gate.
```


```
kubectl explain resourceclaimtemplate.spec
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceClaimTemplate
VERSION:    v1beta1

FIELD: spec <ResourceClaimTemplateSpec>


DESCRIPTION:
    Describes the ResourceClaim that is to be generated.
    
    This field is immutable. A ResourceClaim will get created by the control
    plane for a Pod when needed and then not get updated anymore.
    ResourceClaimTemplateSpec contains the metadata and fields for a
    ResourceClaim.

...
```

## ResourceSlice

```
kubectl get resourceslice
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceSlice
VERSION:    v1beta1

DESCRIPTION:
    ResourceSlice represents one or more resources in a pool of similar
    resources, managed by a common driver. A pool may span more than one
    ResourceSlice, and exactly how many ResourceSlices comprise a pool is
    determined by the driver.
    
    At the moment, the only supported resources are devices with attributes and
    capacities. Each device in a given pool, regardless of how many
    ResourceSlices, must have a unique name. The ResourceSlice in which a device
    gets published may change over time. The unique identifier for a device is
    the tuple <driver name>, <pool name>, <device name>.
    
    Whenever a driver needs to update a pool, it increments the
    pool.Spec.Pool.Generation number and updates all ResourceSlices with that
    new number and new resource definitions. A consumer must only use
    ResourceSlices with the highest generation number and ignore all others.
    
    When allocating all resources in a pool matching certain criteria or when
    looking for the best solution among several different alternatives, a
    consumer should check the number of ResourceSlices in a pool (included in
    each ResourceSlice) to determine whether its view of a pool is complete and
    if not, should wait until the driver has completed updating the pool.
    
    For resources that are not local to a node, the node name is not set.
    Instead, the driver may use a node selector to specify where the devices are
    available.
    
    This is an alpha type and requires enabling the DynamicResourceAllocation
    feature gate.

...
```

```
kubectl explain resourceslice.spec
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceSlice
VERSION:    v1beta1

DESCRIPTION:
    ResourceSlice represents one or more resources in a pool of similar
    resources, managed by a common driver. A pool may span more than one
    ResourceSlice, and exactly how many ResourceSlices comprise a pool is
    determined by the driver.
    
    At the moment, the only supported resources are devices with attributes and
    capacities. Each device in a given pool, regardless of how many
    ResourceSlices, must have a unique name. The ResourceSlice in which a device
    gets published may change over time. The unique identifier for a device is
    the tuple <driver name>, <pool name>, <device name>.
    
    Whenever a driver needs to update a pool, it increments the
    pool.Spec.Pool.Generation number and updates all ResourceSlices with that
    new number and new resource definitions. A consumer must only use
    ResourceSlices with the highest generation number and ignore all others.
    
    When allocating all resources in a pool matching certain criteria or when
    looking for the best solution among several different alternatives, a
    consumer should check the number of ResourceSlices in a pool (included in
    each ResourceSlice) to determine whether its view of a pool is complete and
    if not, should wait until the driver has completed updating the pool.
    
    For resources that are not local to a node, the node name is not set.
    Instead, the driver may use a node selector to specify where the devices are
    available.
    
    This is an alpha type and requires enabling the DynamicResourceAllocation
    feature gate.
    
...
```

```
kubectl explain resourceslice.spec
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceSlice
VERSION:    v1beta1

FIELD: spec <ResourceSliceSpec>


DESCRIPTION:
    Contains the information published by the driver.
    
    Changing the spec automatically increments the metadata.generation number.
    ResourceSliceSpec contains the information published by the driver in one
    ResourceSlice.
    
FIELDS:
  allNodes      <boolean>
    AllNodes indicates that all nodes have access to the resources in the pool.
    
    Exactly one of NodeName, NodeSelector and AllNodes must be set.

  devices       <[]Device>
    Devices lists some or all of the devices in this pool.
    
    Must not have more than 128 entries.

  driver        <string> -required-
    Driver identifies the DRA driver providing the capacity information. A field
    selector can be used to list only ResourceSlice objects with a certain
    driver name.
    
    Must be a DNS subdomain and should end with a DNS domain owned by the vendor
    of the driver. This field is immutable.

  nodeName      <string>
    NodeName identifies the node which provides the resources in this pool. A
    field selector can be used to list only ResourceSlice objects belonging to a
    certain node.
    
    This field can be used to limit access from nodes to ResourceSlices with the
    same node name. It also indicates to autoscalers that adding new nodes of
    the same type as some old node might also make new resources available.
    
    Exactly one of NodeName, NodeSelector and AllNodes must be set. This field
    is immutable.

  nodeSelector  <NodeSelector>
    NodeSelector defines which nodes have access to the resources in the pool,
    when that pool is not limited to a single node.
    
    Must use exactly one term.
    
    Exactly one of NodeName, NodeSelector and AllNodes must be set.

  pool  <ResourcePool> -required-
    Pool describes the pool that this ResourceSlice belongs to.

...
```


```
kubectl explain resourceslice.spec.driver
```

Expected output:
```
GROUP:      resource.k8s.io
KIND:       ResourceSlice
VERSION:    v1beta1

FIELD: driver <string>


DESCRIPTION:
    Driver identifies the DRA driver providing the capacity information. A field
    selector can be used to list only ResourceSlice objects with a certain
    driver name.
    
    Must be a DNS subdomain and should end with a DNS domain owned by the vendor
    of the driver. This field is immutable.
```

## DRA driver 
The DRA driver 
Drivers are OCI container images 
let's check out the driver

```
docker image ls
```

Expected output:
```
REPOSITORY                                                    TAG            IMAGE ID       CREATED          SIZE
registry.example.com/dra-example-driver                       v0.1.0         00b45f4b7b64   53 seconds ago   126MB
registry.k8s.io/dra-example-driver/dra-example-driver-build   golang1.23.1   bfdc38eab2d4   8 minutes ago    1.68GB
registry.example.com/dra-example-driver-build                 golang1.23.1   bfdc38eab2d4   8 minutes ago    1.68GB
kindest/node                                                  v1.32.0        2d9b4b74084a   3 months ago     1.05GB
```