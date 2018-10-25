# Azure Kubernetes Service (AKS) + Azure Active Directory (AAD)

```bash
# see: https://docs.microsoft.com/en-us/azure/aks/aad-integration

RESOURCE_GROUP='181000-aks-aad'
AKS_NAME='aksaad181000'
SERVER_APP_SECRET=''
SERVER_APP_ID=''
CLIENT_APP_ID=''
TENANT_ID=''
# or
# mkdir _/
# c -r _/auth.sh
. _/auth.sh

az account show
az aks list | jq .[].id

az group create -n $RESOURCE_GROUP -l eastus
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --aad-server-app-id $SERVER_APP_ID \
    --aad-server-app-secret $SERVER_APP_SECRET \
    --aad-client-app-id $CLIENT_APP_ID \
    --aad-tenant-id $TENANT_ID \
    --generate-ssh-keys

az aks show \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME

# create namespace and apply clusterrolebinding and rolebinding
kubectl apply -f kubernetes-clb-user-0.yaml

kubectl apply -f kubernetes-ns-user-1.yaml

kubectl apply -f kubernetes-clb-user-1.yaml

# resourcequota
## see: https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/quota-memory-cpu-namespace/

kubectl apply -f kubernetes-resourcequota.yaml --namespace user-1

# admin
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --admin

# non-admin 
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --file -

# confirm / switch contexts
kubeconfig config current-context
kubeconfig config get-contexts
kubeconfig config set-context aksaad181000

# loop over 100 users
# - namespace
# - rolebinding
# - resourcequota

END=100
TEMPLATE_ALL=$(cat kubernetes-template-all.yaml)

# namespace + rolebinding
rm kubernetes-output-all.yaml
for i in $(seq 1 $END); do 
echo "user-${i}"
printf "$TEMPLATE_ALL" $i $i $i $i >> kubernetes-output-all.yaml
done
kubectl apply -f kubernetes-output-all.yaml

# resourcequota
for i in $(seq 1 $END); do 
kubectl apply -f kubernetes-resourcequota.yaml --namespace "user-${i}"
done

# kubectl

## kubeconfig + alias
# cp kubeconfig kubeconfig-user-1
export KUBECONFIG="${PWD}/kubeconfig-user-1"
alias k1='kubectl -n user-1'

k1 get pods
k1 run nginx --image=nginx
k1 delete deploy nginx

```
