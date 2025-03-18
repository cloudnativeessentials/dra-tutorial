# Cluster Setup


## NVIDIA Container Toolkit install 
(Install Docker first and gcc)

gcc install
```
yum install -y gcc
```

Cuda Toolkit install 
```
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
sudo dnf clean all
sudo dnf -y install cuda-toolkit-12-8
```

Nvidia Driver Installer (open kernel module flavor)
with option to skip uninstallable packages
```
sudo dnf -y module install nvidia-driver:open-dkms --skip-broken
```

1. Configure the production repository:

```
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
```

2. Install the NVIDIA Container Toolkit packages:
```
sudo dnf install -y nvidia-container-toolkit
```

3. Configure the NVIDIA Container Runtime as the default Docker runtime:
```
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
```

4. Restart Docker to apply the changes:
```
sudo systemctl restart docker
```

5. Set the accept-nvidia-visible-devices-as-volume-mounts option to true in the /etc/nvidia-container-runtime/config.toml file to configure the NVIDIA Container Runtime to use volume mounts to select devices to inject into a container.
```
sudo nvidia-ctk config --in-place --set accept-nvidia-visible-devices-as-volume-mounts=true
```

6. Install NVIDIA SYstem Management Interface (SMI) 
7. Show the current set of GPUs on the machine:
```
nvidia-smi -L
```

## Install kind on RHEL 

The install-kind-cilium.sh script installs Docker, jq, kind, kubectl, Cilium and creates a kind cluster (1 control plane, 3 worker nodes) on RHEL

To run the script, run the following:

```shell
curl https://raw.githubusercontent.com/cloudnativeessentials/dra-tutorial/refs/heads/main/install-kind-cilium.sh | sh
```

1. Build the image for the resource driver 
```
git clone https://github.com/kubernetes-sigs/dra-example-driver.git
cd dra-example-driver
./demo/build-driver.sh
```

2. Load the driver image into the cluster 
```
./scripts/demo/load-driver-image-into-kind.sh
```