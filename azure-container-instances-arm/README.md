# Azure Container Instances (ACI) in seconds with Azure Resource Manager (ARM)

blog: https://www.aaronmsft.com/posts/azure-container-instances-arm/


# 1. Deploy ARM Template via Azure CLI

```bash
RESOURCE_GROUP='180400-test'
LOCATION='eastus'

# create a resource group
az group create -l $LOCATION -n $RESOURCE_GROUP

# deploy a local template with default parameters
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-file azuredeploy.json

# deploy our local template with default parameters
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-uri https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-container-instances-arm/azuredeploy.json

# deploy our template with parameters
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-uri https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-container-instances-arm/azuredeploy.json --parameters region1Count=3 region2Count=3 region3Count=3

# deploy an empty template to delete our resources
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-uri https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-container-instances-arm/empty.json
```

# 2. Deploy ARM Template via Azure Portal

```
TEMPLATE_URL='https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-container-instances-arm/azuredeploy.json'
OUTPUT_URL='https://portal.azure.com/#create/Microsoft.Template/uri/'$(echo $TEMPLATE_URL | jq -s -R -r @uri )
echo $OUTPUT_URL


# 3. dig + curl
# -------------

DNS_NAME='tm-acqa4vg2wossw'
# name server sourced via: dig +short trafficmanager.net NS
while true; do
    CONTAINER_HOST=$(dig +short @tm1.msft.net $DNS_NAME'.trafficmanager.net' | sed -e 's/\.$//')
    curl --connect-timeout 1 'http://'$CONTAINER_HOST'/host'
    sleep 1
done
```
