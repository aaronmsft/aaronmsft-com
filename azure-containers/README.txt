# VARIABLES
# ---------
RESOURCE_GROUP='180300-demo'
LOCATION='eastus'
REGISTRY_NAME='acr180300demo'
CONTAINER_NAME='container-1'
CLUSTER_NAME='aks180300demo'
WEBAPP_NAME='hello-webapp-180300'
DIR=$(pwd)


# AZURE RESOURCE_GROUP
# --------------------

az group create -n $RESOURCE_GROUP -l $LOCATION


# AZURE CONTAINER REGISTRY (ACR)
# ------------------------------

az acr create -n $REGISTRY_NAME -g $RESOURCE_GROUP --sku Basic --admin-enabled true

az acr login -n $REGISTRY_NAME

PASSWORD=$(az acr credential show --name $REGISTRY_NAME | jq -r .passwords[0].value)


# DOCKER
# ------

# hello-golang 
cd $DIR/golang

GOOS=linux GOARCH=amd64 go build -o main main.go

docker build -f Dockerfile -t "hello-golang" .

docker run --rm -p 8080:8080/tcp -it hello-golang

docker tag hello-golang $REGISTRY_NAME'.azurecr.io/demo/hello-golang'
docker push $REGISTRY_NAME'.azurecr.io/demo/hello-golang'

# hello-python 
cd $DIR/python

docker build -f Dockerfile -t "hello-python" .

docker run --rm -p 8080:8080/tcp -it hello-python

docker tag hello-python $REGISTRY_NAME'.azurecr.io/demo/hello-python'
docker push $REGISTRY_NAME'.azurecr.io/demo/hello-python'


# AZURE CONTAINER INSTANCES (ACI)
# -------------------------------

az container create -g $RESOURCE_GROUP --name $CONTAINER_NAME --cpu 1 --memory 1 \
    --ip-address public \
    --registry-login-server $REGISTRY_NAME'.azurecr.io' \
    --registry-username $REGISTRY_NAME \
    --registry-password $PASSWORD \
    --image $REGISTRY_NAME'.azurecr.io/demo/hello-golang:latest' \
    --port 8080

az container show -g $RESOURCE_GROUP --name $CONTAINER_NAME

az container show -g $RESOURCE_GROUP --name $CONTAINER_NAME | jq .containers[0].instanceView.events[]

IP_ADDRESS=$(az container show -g $RESOURCE_GROUP --name $CONTAINER_NAME | jq -r .ipAddress.ip)

echo 'http://'$IP_ADDRESS':8080'

open 'http://'$IP_ADDRESS':8080'

az container logs -g $RESOURCE_GROUP --name $CONTAINER_NAME

# single
curl --connect-timeout 1 'http://'$IP_ADDRESS':8080'

# loop
while true; do
    curl 'http://'$IP_ADDRESS':8080' --connect-timeout 1 
done

az container delete -y -g $RESOURCE_GROUP --name $CONTAINER_NAME


# AZURE CONTAINER SERVICE (AKS)
# -----------------------------

az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME \
    --location $LOCATION \
    --node-count 2 \
    --node-vm-size Standard_D2_v2 \
    --kubernetes-version 1.8.7 \
    --generate-ssh-keys

az aks get-versions --location $LOCATION 

az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME

az aks browse -g $RESOURCE_GROUP -n $CLUSTER_NAME

az aks install-cli

kubectl create secret docker-registry regcred --docker-server=$REGISTRY_NAME'.azurecr.io' \
    --docker-username=$REGISTRY_NAME \
    --docker-password=$PASSWORD \
    --docker-email=user@example.org

kubectl run hello-golang --image=$REGISTRY_NAME'.azurecr.io/demo/hello-golang:latest' --port=8080 \
    --overrides='{ "apiVersion": "extensions/v1beta1", "spec": {"template": {"spec": { "imagePullSecrets": [{"name": "regcred"}] } } } }'
    
kubectl expose deploy hello-golang --port=80 --target-port=8080 --type=LoadBalancer

kubectl get service --watch

IP_ADDRESS=$(kubectl get service hello-golang -o json | jq -r .status.loadBalancer.ingress[0].ip)

kubectl scale deployments/hello-golang --replicas=3

kubectl edit deploy hello-golang

az aks scale -g $RESOURCE_GROUP -n $CLUSTER_NAME --node-count 2

az aks get-upgrades -g $RESOURCE_GROUP -n $CLUSTER_NAME

az aks upgrade -g $RESOURCE_GROUP -n $CLUSTER_NAME --kubernetes-version 1.8.7

# test

curl --connect-timeout 1 'http://'$IP_ADDRESS

open 'http://'$IP_ADDRESS

# /
while true; do
    curl 'http://'$IP_ADDRESS'/'
    sleep 1
done

# /host
while true; do
    curl 'http://'$IP_ADDRESS'/host'
    sleep 1
done


# HELM
# ----

# brew install kubernetes-helm

helm init

helm repo update

helm search wordpress

helm install stable/wordpress

helm install stable/ghost

helm delete ...


# DRAFT
# -----

# install
brew tap azure/draft
brew install draft

# uninstall
brew uninstall --force draft
rm -rf ~/.draft/

draft init

draft config set registry $REGISTRY_NAME'.azurecr.io'

cd $DIR/python-draft

draft create

# if neccessary
draft delete

draft up

draft connect

# speed-up?
draft delete
rm -rf charts/ .draftignore Dockerfile draft.toml
draft create
draft up
draft connect


# WEB APP FOR CONTAINERS
# ----------------------

# Docs: https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-intro

az appservice plan create -g $RESOURCE_GROUP -n AppServiceLinux --is-linux --sku S1

# nginx
az webapp create -g $RESOURCE_GROUP --plan AppServiceLinux -n $WEBAPP_NAME \
    --deployment-container-image-name nginx

# deploy hello-golang
az webapp config container set -g $RESOURCE_GROUP -n $WEBAPP_NAME \
    --docker-registry-server-url 'https://'$REGISTRY_NAME'.azurecr.io/' \
    --docker-registry-server-user $REGISTRY_NAME \
    --docker-registry-server-password $PASSWORD \
    --docker-custom-image-name $REGISTRY_NAME'.azurecr.io/demo/hello-golang:latest'

az webapp config container set -g $RESOURCE_GROUP -n $WEBAPP_NAME \
   --docker-custom-image-name nginx

az webapp log tail -g $RESOURCE_GROUP -n $WEBAPP_NAME


# TEST
# ----

# http | docker | delivery | slots | testing | scale

echo $WEBAPP_NAME.azurewebsites.net

curl $WEBAPP_NAME'.azurewebsites.net'

hey 'https://'$WEBAPP_NAME'.azurewebsites.net'

hey -c 50 -n 100000 'https://'$WEBAPP_NAME'.azurewebsites.net'


# DOCS & RESOURCES
# ----------------

Azure Cloud Shell
- https://docs.microsoft.com/en-us/azure/cloud-shell/overview
Visual Studio Code
- https://code.visualstudio.com/docs/editor/integrated-terminal
Azure CLI
- https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
Docker
- https://docs.microsoft.com/en-us/azure/container-instances/container-instances-tutorial-prepare-app#build-the-container-image
Azure Container Registry (ACR)
- https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli
Azure Container Instances (ACI)
- https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quickstart
Azure Container Services (AKS)
- https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough
Helm
- https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm
Draft
- https://docs.microsoft.com/en-us/azure/aks/kubernetes-draft
Web App for Containers
- https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image
