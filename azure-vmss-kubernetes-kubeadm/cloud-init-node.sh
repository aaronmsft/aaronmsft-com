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


# kubeadm - agent nodes
# ---------------------
# initialize agent node
kubeadm join --discovery-token-unsafe-skip-ca-verification --token '8f07c4.2fa8f9e48b6d4036' 10.0.0.4:6443


# --------------------------------------------
echo 'configuration complete' > /tmp/hello.txt
