# Azure Front Door (AFD) with Azure Container Instances (ACI) across multiple regions using Azure Resource Manager (ARM) Templates

## Azure Portal

If you would like to deploy via the Azure Portal you can use the following link:

[Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faaronmsft%2Faaronmsft-com%2Fmaster%2Fazure-front-door-container-instances-arm%2Fazuredeploy.json%0A)

The link above was was generated via the following snippet:

```bash
TEMPLATE_URL='https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-front-door-container-instances-arm/azuredeploy.json'
OUTPUT_URL='https://portal.azure.com/#create/Microsoft.Template/uri/'$(echo $TEMPLATE_URL | jq -s -R -r @uri )
echo $OUTPUT_URL
```

## Azure CLI

```bash
RESOURCE_GROUP='190400-afd-aci'
LOCATION='eastus'

az group create -n $RESOURCE_GROUP -l $LOCATION

# deploy azure front door from url
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-uri https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-front-door-container-instances-arm/azuredeploy.json

# deploy azure front door locally with parameter
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-file azuredeploy.json \
    --parameters image=nginx

# deploy front door and azure traffic manager locally with parameter
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-file azuredeploy-fd-tm.json \
    --parameters image=nginx

# deploy an empty template to delete our resources
az group deployment create -g $RESOURCE_GROUP --mode Complete --template-uri https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-container-instances-arm/empty.json
```
