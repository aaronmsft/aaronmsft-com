# Docker, Azure Containers (Container Registry, Container Instances, Kubernetes Service)

## Docker

1. Create [Dockerfile](Dockerfile)

```
FROM gradle:jdk10 as builder
USER root
WORKDIR /home/gradle/
COPY . /home/gradle/
RUN gradle clean assemble

FROM openjdk:10-slim
WORKDIR /home/
COPY --from=builder /home/gradle/build/libs/spring-music.jar /home/
ENTRYPOINT [ "java", "-XX:+UnlockExperimentalVMOptions", "-jar", "/home/spring-music.jar" ]
```

2. Build and debug locally

```bash
# build & run
docker build -t test .
docker run --rm -p 8080:8080/tcp -it test

# build & debug
docker build -t test . 
docker run --rm --entrypoint bash -p 8080:8080/tcp -it test
java -jar /home/spring-music.jar
```

# Azure

## Deploy Azure Container Registry and Azure Kubernetes Service

1. Set bash variables and create Resource Group.

```bash
RESOURCE_GROUP='180900-test'
LOCATION='eastus'
if [ -z "$RANDOM_STR" ]; then RANDOM_STR=$(openssl rand -hex 3); else echo $RANDOM_STR; fi
CONTAINER_REGISTRY=acr${RANDOM_STR}
CONTAINER_IMAGE='spring-music:v1'
KUBERNETES_SERVICE=aks${RANDOM_STR}

az group create --name $RESOURCE_GROUP --location $LOCATION
```

2. Create [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli#create-a-container-registry) and [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#create-aks-cluster)

```bash
az acr create -g $RESOURCE_GROUP -n $CONTAINER_REGISTRY --sku Basic

az aks create -g $RESOURCE_GROUP -n $KUBERNETES_SERVICE --node-count 3 --generate-ssh-keys

# install cli and connect to aks cluster
az aks install-cli
az aks get-credentials -g $RESOURCE_GROUP -n $CONTAINER_SERVICE
```

3. [Grant Azure Kubernetes Service access to Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks#grant-aks-access-to-acr)


```bash
# get the id of the service principal configured for AKS, get the ACR registry resource id, and create role assignment
CLIENT_ID=$(az aks show -g $RESOURCE_GROUP -n $KUBERNETES_SERVICE --query "servicePrincipalProfile.clientId" --output tsv)
CONTAINER_REGISTRY_ID=$(az acr show -g $RESOURCE_GROUP -n $CONTAINER_REGISTRY --query "id" --output tsv)
az role assignment create --assignee $CLIENT_ID --scope $CONTAINER_REGISTRY_ID --role Reader
```

## Build application using Azure Container Registry Build

See: [Azure Container Registry Tutorial](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-build)

```bash
az acr build --registry $CONTAINER_REGISTRY --image $CONTAINER_IMAGE .
```

## Deploy application to Azure Container Instances

See: [Azure Container Instances Quickstart](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quickstart#create-a-container)

```bash
# enable admin credentials
az acr update -n $CONTAINER_REGISTRY --admin-enabled true
CONTAINER_REGISTRY_PASSWORD=$(az acr credential show -n $CONTAINER_REGISTRY | jq -r .passwords[0].value)

# create container instance
az container create --resource-group $RESOURCE_GROUP --location $LOCATION \
    --name aci${RANDOM_STR} \
    --image "${CONTAINER_REGISTRY}.azurecr.io/${CONTAINER_IMAGE}" \
    --registry-login-server "${CONTAINER_REGISTRY}.azurecr.io" \
    --registry-username $CONTAINER_REGISTRY \
    --registry-password $CONTAINER_REGISTRY_PASSWORD \
    --cpu 1 \
    --memory 1 \
    --ports 8080 \
    --dns-name-label aci${RANDOM_STR}

# show container events
az container show -g $RESOURCE_GROUP -n aci${RANDOM_STR} | jq .containers[0].instanceView.events[]

CONTAINER_INSTANCE_FQDN=$(az container show -g $RESOURCE_GROUP -n aci${RANDOM_STR} | jq -r .ipAddress.fqdn)

curl "${CONTAINER_INSTANCE_FQDN}:8080"

open "http://${CONTAINER_INSTANCE_FQDN}:8080"
```

## Deploy application to Azure Kubernetes Service

1. Set `image: ...` in [kubernetes-deploy.yaml](kubernetes-deployment.yaml) to the fully qualified image name which can be found via:

```bash
echo "${CONTAINER_REGISTRY}.azurecr.io/${CONTAINER_IMAGE}"
```

2. Deploy the application to Azure Kuberentes Service:

```bash
# create deployment
kubectl apply -f kubernetes-deployment.yaml

kubectl get deploy --watch

kubectl port-forward deploy/spring-music 9090:8080

kubectl describe deploy spring-music

kubectl get pods

kubectl logs ...

kubectl scale deployment spring-music --replicas=1

# create service
kubectl apply -f kubernetes-service.yaml

kubectl port-forward service/spring-music 9090:80

kubectl get service --watch

IP_ADDRESS=$(kubectl get service spring-music -o json | jq -r .status.loadBalancer.ingress[0].ip)

curl $IP_ADDRESS

open "http://${IP_ADDRESS}"
```

## Resources

- https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment
