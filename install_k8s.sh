#!/bin/bash

set -e

echo "Mise à jour du système..."
sudo apt-get update && sudo apt-get upgrade -y

echo "Désactivation du swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Installation des paquets nécessaires..."
sudo apt-get install -y apt-transport-https ca-certificates curl

echo "Ajout de la clé GPG Kubernetes..."
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "Ajout du dépôt Kubernetes..."
sudo bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF'

echo "Installation kubeadm, kubelet, kubectl..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Initialisation du cluster Kubernetes..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "Configuration kubectl pour l'utilisateur courant..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Installation du réseau Flannel..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "Cluster Kubernetes initialisé avec succès !"
echo "Pour joindre des nœuds au cluster, utilisez la commande kubeadm join affichée à la fin de 'kubeadm init'."
