#!/bin/bash

sudo apt update -y && sudo apt upgrade -y
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

kind version

kind create cluster --name clusterEntrega2