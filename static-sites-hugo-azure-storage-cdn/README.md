# Static sites on Azure Storage with Custom Domain and HTTPS via Azure CDN (Microsoft)

blog: coming soon!

# Requirements

- bash / Cloud Shell: https://docs.microsoft.com/en-ca/azure/cloud-shell/quickstart
- Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- Azure CLI storage-preview extension: https://github.com/Azure/azure-cli-extensions/tree/master/src/storage-preview
- Hugo: https://gohugo.io/

# Azure Storage

```bash
az extension add --name storage-preview

RESOURCE_GROUP='180600-static-site'
LOCATION='eastus'
STORAGE_ACCOUNT='180600static'
STORAGE_CONTAINER='$web'

az group create -n $RESOURCE_GROUP -l $LOCATION

az storage account create -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT \
    --location $LOCATION --kind StorageV2 --sku Standard_LRS

az storage blob service-properties update \
    --account-name $STORAGE_ACCOUNT \
    --static-website \
    --404-document error.html \
    --index-document index.html

WEB_ENDPOINT=$(az storage account show -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT | jq -r .primaryEndpoints.web)

export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT | jq -r .connectionString)
```

# hugo + az

```bash
git clone git@github.com:aaronmsft/hello-hugo.git
cd hello-hugo/
hugo

UNMODIFIED_SINCE=$(date -u -v-5M '+%Y-%m-%dT%H:%MZ')
az storage blob upload-batch --source public/ --destination $STORAGE_CONTAINER
az storage blob delete-batch --source $STORAGE_CONTAINER --if-unmodified-since $UNMODIFIED_SINCE

cd ../

echo $WEB_ENDPOINT
```

# Azure CDN (Microsoft)

```bash
WEB_HOSTNAME=$(echo $WEB_ENDPOINT | awk -F/ '{print $3}')
PROFILE_NAME="cdn180629"
ENDPOINT_NAME="cdn180629" # must be globally unique
CUSTOMDOMAIN_HOSTNAME=""

# deploy with a custom domain name. point to $ENDPOINT_NAME.azureedge.net and check propagation.
# CUSTOMDOMAIN_HOSTNAME="cdn.aaronmsft.com"
# dig +short $CUSTOMDOMAIN_HOSTNAME

# deploy arm template from template-uri
az group deployment create -g $RESOURCE_GROUP --mode Incremental \
    --template-uri https://raw.githubusercontent.com/aaronmsft/aaronmsft-com/master/static-sites-hugo-azure-storage-cdn//azuredeploy.json \
    --parameters origins_hostname=$WEB_HOSTNAME profiles_name=$PROFILE_NAME endpoints_name=$ENDPOINT_NAME customdomains_hostname=$CUSTOMDOMAIN_HOSTNAME

# or deploy arm template from template-file
az group deployment create -g $RESOURCE_GROUP --mode Incremental --template-file azuredeploy.json \
    --parameters origins_hostname=$WEB_HOSTNAME profiles_name=$PROFILE_NAME endpoints_name=$ENDPOINT_NAME customdomains_hostname=$CUSTOMDOMAIN_HOSTNAME

# or: deploy arm template via azure portal
https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faaronmsft%2Faaronmsft-com%2Fmaster%2Fstatic-sites-hugo-azure-storage-cdn%2F%2Fazuredeploy.json%0A

# enable https for custom domain name
CUSTOMDOMAIN_NAME=$(az cdn custom-domain list -g $RESOURCE_GROUP --profile-name $PROFILE_NAME --endpoint-name $ENDPOINT_NAME | jq -r '.[] | select(.hostName == "'$CUSTOMDOMAIN_HOSTNAME'") | .name')

az cdn custom-domain enable-https -g $RESOURCE_GROUP --profile-name $PROFILE_NAME --endpoint-name $ENDPOINT_NAME --name $CUSTOMDOMAIN_NAME

az cdn custom-domain list -g $RESOURCE_GROUP --profile-name $PROFILE_NAME --endpoint-name $ENDPOINT_NAME | jq -r '.[] | select(.hostName == "'$CUSTOMDOMAIN_HOSTNAME'") | .'
```

# Resources

- https://azure.microsoft.com/en-us/blog/azure-storage-static-web-hosting-public-preview/
- https://github.com/Azure/azure-cli-extensions/tree/master/src/storage-preview
- https://azure.microsoft.com/en-us/blog/announcing-microsoft-s-own-cdn-network/
- https://docs.microsoft.com/en-us/cli/azure/storage
- https://docs.microsoft.com/en-us/cli/azure/group/deployment
- https://docs.microsoft.com/en-us/cli/azure/cdn
- https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website
- https://docs.microsoft.com/en-us/azure/storage/blobs/storage-https-custom-domain-cdn
