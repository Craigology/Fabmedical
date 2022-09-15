#!/bin/bash

# Check if SUFFIX envvar exists
if [[ -z "${MCW_SUFFIX}" ]]; then
    echo "Please set the MCW_SUFFIX environment variable to a unique three character string."
    exit 1
fi

if [[ -z "${MCW_GITHUB_USERNAME}" ]]; then
    echo "Please set the MCW_GITHUB_USERNAME environment variable to your Github Username"
    exit 1
fi

if [[ -z "${MCW_GITHUB_TOKEN}" ]]; then
    echo "Please set the MCW_GITHUB_TOKEN environment variable to your Github Token"
    exit 1
fi

if [[ -z "${MCW_GITHUB_URL}" ]]; then
    MCW_GITHUB_URL=https://$MCW_GITHUB_USERNAME:$MCW_GITHUB_TOKEN@github.com/$MCW_GITHUB_USERNAME/Fabmedical.git
fi

# Install essentials
sudo apt-get update -y
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install curl python-software-properties -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get update -y && sudo apt-get install -y docker-ce nodejs mongodb-clients
sudo apt-get upgrade -y

docker version
nodejs --version
npm -version

# Install Angular
sudo npm install -g @angular/cli

# Remove sudo requirement
sudo usermod -aG docker $USER

# Ensure we own our home
sudo chown -R $USER:$(id -gn $USER) /home/adminfabmedical/.config

# Create Fabmedical repository
if [[ ! -e ~/Fabmedical ]]; then
    GIT_AUTH=$(echo -n "$MCW_GITHUB_USERNAME:$MCW_GITHUB_TOKEN" | openssl base64 | tr -d '\n')
    git config --global http.$MCW_GITHUB_URL.extraHeader "Authorization: Basic $GIT_AUTH"
    git clone https://github.com/$MCW_GITHUB_USERNAME/Fabmedical ~/Fabmedical
fi
