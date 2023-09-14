#!/bin/bash

USER="$(whoami)"
# Update the minimal install
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USER"
sudo apt update && sudo apt upgrade

# Install Utilities and miscellaneous tools
sudo apt install -y curl wget jq moreutils git unzip zip ca-certificates apt-transport-https lsb-release gnupg gpg software-properties-common

# Install VSCode
wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' && \
sudo apt install ./vscode.deb && \
rm -f ./vscode.deb

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
sudo ./aws/install && \
rm awscliv2.zip

# Azure CLI
# NOTE: if using a 23.04 distro, change "(lsb_release -cs)" to "jammy" (22.04)
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
echo "deb [arch="$(dpkg --print-architecture)"] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list && \
sudo apt update && \
sudo apt install -y azure-cli
 
# GCloud CLI
echo deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
sudo apt update -y && \
sudo apt install google-cloud-sdk -y

# Powershell
# NOTE: if using a 23.04 distro, change "$(lsb_release -rs)" to "22.04" (jammy)
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" && \
sudo dpkg -i packages-microsoft-prod.deb && \
rm packages-microsoft-prod.deb && \
sudo apt update && \
sudo apt install -y powershell

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

# Terraform
# NOTE: if using a 23.04 distro, change "$(lsb_release -cs)" to "jammy"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null && \
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && \
sudo apt update && \
sudo apt install -y terraform