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
```