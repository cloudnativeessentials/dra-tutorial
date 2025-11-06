#!/bin/bash
set -e

echo "This script installs Docker, kind, kubectl, and creates a kind cluster"
echo "This will take several minutes to complete"

# install docker 
echo "Installing docker"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

# install jq
echo "Installing jq"
sudo yum install -y jq

# install git
echo "Installing git"
sudo yum install -y git

# install kind for AMD64/x86_64
echo "Installing kind"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
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
nodes:
- role: control-plane
- role: worker
  extraPortMappings:
  - containerPort: 11434
    hostPort: 11434
EOF

# create kind cluster using kind-config.yaml
sg docker -c 'kind create cluster --image=kindest/node:v1.34.0 --config=kind-config.yaml'

# install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

#finish
echo "kind cluster is ready"
exit

