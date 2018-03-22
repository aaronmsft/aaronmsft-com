#!/bin/sh
# -------

# install docker & kubeadm - ubuntu
# ---------------------------------

# update and upgrade packages
apt-get update && apt-get upgrade -y

# install docker
apt-get install -y docker.io

# install kubeadm
apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl

# kubeadm - master node
# ---------------------
# initialize master
kubeadm init --pod-network-cidr=192.168.0.0/16  --token '8f07c4.2fa8f9e48b6d4036'

# confirm output and copy "kubeadm join" command.

# copy /etc/kubernetes/admin.conf so we can use kubectl
sudo cp -i /etc/kubernetes/admin.conf /home/kubeconfig
sudo chown $(id -u):$(id -g) /home/kubeconfig

export KUBECONFIG='/etc/kubernetes/admin.conf'

# install pod network
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

# --------------------------------------------
echo 'configuration complete' > /tmp/hello.txt
