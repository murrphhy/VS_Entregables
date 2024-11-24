#!/bin/bash

# Instalación de Docker
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker

# Añadir al usuario 'vagrant' al grupo de Docker para ejecutar comandos sin sudo
sudo usermod -aG docker vagrant

# Verificar la instalación de Docker
docker --version

# Actualización de los paquetes que nos vienen de inicio.
sudo apt-get update -y && sudo apt-get upgrade -y

# Instalación Kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Comprobación de la instalación de Kind
kind version

# Instalación de kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Verificar la instalación de kubectl
kubectl version --client --output=yaml
