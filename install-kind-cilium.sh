#!/bin/bash
set -e

echo "This script installs Docker, kind, kubectl, and creates a kind cluster"
echo "This will take several minutes to complete"

# install make
echo "Installing make"
sudo yum install -y make

# install tar
echo "Installing tar"
sudo yum install -y tar

# install docker 
echo "Installing docker"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker
docker buildx install

# install jq
echo "Installing jq"
sudo yum install -y jq

# install kind for AMD64/x86_64
echo "Installing kind"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# download kubectl binary
echo "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# download kubectl checksum file
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# validate kubectl binary with checksum file
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# create kind-config.yaml with heredoc
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  DynamicResourceAllocation: true
containerdConfigPatches:
# Enable CDI as described in
# https://tags.cncf.io/container-device-interface#containerd-configuration
- |-
  [plugins."io.containerd.grpc.v1.cri"]
    enable_cdi = true
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
        extraArgs:
          runtime-config: "resource.k8s.io/v1beta1=true"
    scheduler:
        extraArgs:
          v: "1"
    controllerManager:
        extraArgs:
          v: "1"
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        v: "1"
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        v: "1"
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        v: "1"
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        v: "1"
# networking:
#  disableDefaultCNI: true
EOF

# create kind cluster using kind-config.yaml
sg docker -c 'kind create cluster --image=kindest/node:v1.32.0 --config=kind-config.yaml'

# install cilium cli
# echo "Installing cilium"
# export CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
# export CLI_ARCH=amd64
# if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
# curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
# sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
# rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# cilium install

# wait until cilium is up and running
# echo "Waiting until cilium is up and running"
# cilium status --wait

# install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sh

#finish
echo "kind cluster is ready"
exit

