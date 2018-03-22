# Explore Kubernetes and Azure Low-priority VMs on Virtual Machine Scale Sets with kubeadm
# ----------------------------------------------------------------------------------------

blog: https://www.aaronmsft.com/posts/azure-vmss-kubernetes-kubeadm/

# 1. azure
# --------

RESOURCE_GROUP='180300-k8s-vmss'
LOCATION='eastus'
IMAGE='UbuntuLTS'
MASTER_SKU='Standard_D1_v2'
AGENT_SKU='Standard_D1_v2'

az group create -g $RESOURCE_GROUP -l $LOCATION

az vm create -g $RESOURCE_GROUP -n 'linux1' \
    --size $MASTER_SKU \
    --image $IMAGE \
    --public-ip-address-dns-name 'ip1-'$RESOURCE_GROUP \
    --vnet-name vnet1 \
    --subnet subnet1 \
    --custom-data cloud-init-master.sh \
    --generate-ssh-keys

az vmss create -g $RESOURCE_GROUP -n vmss0 \
    --vm-sku $AGENT_SKU \
    --image UbuntuLTS \
    --public-ip-address-dns-name 'lb1-'$RESOURCE_GROUP \
    --upgrade-policy-mode automatic \
    --instance-count 2 \
    --vnet-name vnet1 \
    --subnet subnet1 \
    --custom-data cloud-init-node.sh \
    --priority Low \
    --generate-ssh-keys


# 2. master node (vm)
# -------------------

# ssh into master node
ssh $USER'@ip'$TMP_I'-'$RESOURCE_GROUP'.'$LOCATION'.cloudapp.azure.com'

sudo chown $(id -u):$(id -g) /home/kubeconfig
export KUBECONFIG=/home/kubeconfig

kubectl get nodes


# 3. agent nodes (vmss)
# ---------------------

# check the status of your instances
az vmss get-instance-view -g $RESOURCE_GROUP -n vmss0 --instance-id '*'

# ssh into vmss node
INSTANCE_ID=$(az vmss list-instances -g $RESOURCE_GROUP -n vmss0 | jq -r .[0].instanceId)
ssh $USER'@lb1-'$RESOURCE_GROUP'.'$LOCATION'.cloudapp.azure.com' -p '5000'$INSTANCE_ID

# confirm cloud-init is complete
cat /tmp/hello.txt
tail -f /var/log/cloud-init.log
tail -f /var/log/cloud-init-output.log


# 4. kubectl job (on master node)
# -------------------------------

kubectl create -f https://raw.githubusercontent.com/kubernetes-up-and-running/examples/master/10-1-job-oneshot.yaml

kubectl describe jobs/oneshot

kubectl create -f https://raw.githubusercontent.com/kubernetes-up-and-running/examples/master/10-3-job-parallel.yaml

kubectl describe jobs/parallel

kubectl get pods
