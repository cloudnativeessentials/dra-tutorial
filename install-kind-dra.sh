#!/bin/bash
set -e

echo "This script installs prereqs Docker, kind, kubectl, and creates a kind cluster"
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
# sudo usermod -aG docker $USER
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

# git clone dra driver
git clone https://github.com/reylejano/dra-example-driver.git
cd dra-example-driver

# build driver
./demo/build-driver.sh

# create kind cluster 
./demo/create-cluster.sh

# create kind-config.yaml with heredoc
# cat <<EOF > kind-config.yaml
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# feat
#    apiServer:
#        extraArgs:
#          runtime-config: "resource.k8s.io/v1beta1=true"
#    scheduler:
#        extraArgs:
#          v: "1"
#    controllerManager:
#        extraArgs:
#          v: "1"
#  - |
#    kind: InitConfiguration
#    nodeRegistration:
#      kubeletExtraArgs:
#        v: "1"
#- role: worker
#  kubeadmConfigPatches:
#  - |
#    kind: JoinConfiguration
#    nodeRegistration:
#      kubeletExtraArgs:
#        v: "1"
#- role: worker
#  kubeadmConfigPatches:
#  - |
#    k ind: JoinConfiguration
#    nodeRegistration:
#      kubeletExtraArgs:
#        v: "1"
#- role: worker
#  kubeadmConfigPatches:
#  - |
#    kind: JoinConfiguration
#    nodeRegistration:
#      kubeletExtraArgs:
#        v: "1"
# networking:
#  disableDefaultCNI: true
#EOF

# create kind cluster using kind-config.yaml
# sg docker -c 'kind create cluster --image=kindest/node:v1.32.0 --config=kind-config.yaml'


# install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sh

# install cert-manager with webhook.enabled=true 
helm install \
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

