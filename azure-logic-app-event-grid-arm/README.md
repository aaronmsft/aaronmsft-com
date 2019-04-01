# Azure Logic App + Event Grid + Azure Resource Manager (ARM)

This ARM template will deploy a Logic App that is triggered via Event Grid and Azure Resource Manager events.

The Logic App for the creation of Resource Groups named with the suffix _del_X, where X is a unit of duration.

Upon creation of a Resource Group with this suffix, the Logic App will wait X Minutes (Default), Hours, Days, etc, then delete the Resource Group.

You can deploy this template via the following Azure CLI command:

```bash
az group deployment create -g $RESOURCE_GROUP --template-url https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/azure-logic-app-event-grid-arm/azuredeploy.json
```

Or click https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faaronmsft%2Faaronmsft-com%2Fmaster%2Fazure-logic-app-event-grid-arm%2Fazuredeploy.json%0A to deploy it via the Azure Portal.

After deployment, you will need to open the Azure Portal and click on the two API Connections ("eventgrid" and "resourcemanager") that have been created in your Resource Group, and authorize them.
