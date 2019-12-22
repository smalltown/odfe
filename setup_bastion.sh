#!/bin/bash

echo "Install kubectl"

sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

echo "Install helm"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo "Install helmfile"
curl -L -o helmfile https://github.com/roboll/helmfile/releases/download/v0.97.0/helmfile_linux_amd64
sudo mv helmfile /usr/local/bin/
sudo chmod +x /usr/local/bin/helmfile
