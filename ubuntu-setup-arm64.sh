#!/bin/bash

USER="<username>"
# Update the minimal install
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USER"
sudo apt update && sudo apt upgrade

# Install Utilities
sudo apt install -y curl wget jq moreutils git unzip zip ca-certificates apt-transport-https lsb-release gnupg gpg software-properties-common

# Install VSCode
wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64' && \
sudo apt install ./vscode.deb && \
rm -f ./vscode.deb

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
sudo ./aws/install && \
rm awscliv2.zip

# Azure CLI
# NOTE: if using a 23.04 distro, change 'AZ_REPO="jammy"' (22.04)
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
AZ_REPO=$(lsb_release -cs) && \
echo "deb [arch="$(dpkg --print-architecture)"] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list && \
sudo apt update && \
sudo apt install -y azure-cli
 
# GCloud CLI
echo deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
sudo apt update -y && \
sudo apt install google-cloud-sdk -y

# Powershell
# NOTE: if using a 23.04 distro, change "$(lsb_release -rs)" to "22.04" (jammy)
# NOTE: arm64 version has to be installed manually, not from repository
curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/powershell-7.3.6-linux-arm64.tar.gz -o /tmp/powershell.tar.gz && \
sudo mkdir -p /opt/microsoft/powershell/7 && \
sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
sudo chmod +x /opt/microsoft/powershell/7/pwsh && \
sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
rm -f /tmp/powershell.tar.gz

# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
# NOTE: if using a 23.04 distro, change "$VERSION_CODENAME" to "jammy" for 22.04
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Resolve issues for Docker and Elasticsearch
sudo sysctl -w fs.inotify.max_user_watches=524288 && \
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf && \
sudo sysctl -w vm.max_map_count=262144 && \
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf