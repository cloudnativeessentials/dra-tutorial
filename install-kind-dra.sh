#!/bin/bash
set -e

echo "This script installs prereqs Docker, kind, kubectl, and creates a kind cluster"
echo "This will take several minutes to complete"

# install make
echo "Installing make"
dnf install -y make

# install tar
echo "Installing tar"
dnf install -y tar

# install docker 
echo "Installing docker"
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker
docker buildx install

# install jq
yum install -y jq

# install kind for AMD64/x86_64
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# download kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# download kubectl checksum file
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# validate kubectl binary with checksum file
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# install kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# git clone dra driver
git clone https://github.com/reylejano/dra-example-driver.git

# build drivercd
./dra-example-driver/demo/build-driver.sh

# create kind cluster 
./dra-example-driver/demo/create-cluster.sh

# install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sh

# install cert-manager with webhook.enabled=true 
helm upgrade -i \
  --repo https://charts.jetstack.io \
  --version v1.16.3 \
  --create-namespace \
  --namespace cert-manager \
  --wait \
  --set crds.enabled=true \
  cert-manager \
  cert-manager

# install dra driver 
helm upgrade -i \
  --create-namespace \
  --namespace dra-example-driver \
  dra-example-driver \
  deployments/helm/dra-example-driver

#finish
echo "kind cluster is ready"
exit

