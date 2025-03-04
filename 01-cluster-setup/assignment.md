---
slug: cluster-setup
id: <id>
type: challenge
title: Cluster Setup
teaser: Setup a kind Kubernetes cluster
notes:
- type: text
  contents: "Welcome to the Tutorial: Unlock the future of Kubernetes and accelerators (and all specialized hardware) with Dynamic Resource Allocation.\n\nWe will setup a Kubernete Cluster, use the Dynamic Resource Allocation feature to maximize GPU workloads."
tabs:
- id: <id>
  title: Terminal
  type: terminal
  hostname: server
difficulty: ""
enhanced_loading: null
---
# Cluster Setup

## Install kind on RHEL 

The install-kind-cilium.sh script installs Docker, jq, kind, kubectl, Cilium and creates a kind cluster (1 control plane, 3 worker nodes) on RHEL

To run the script, run the following:

```shell
curl https://raw.githubusercontent.com/cloudnativeessentials/dra-tutorial/refs/heads/main/install-kind-cilium.sh | sh
```
