# Static Sites with Hugo, Azure Blob Storage and Cloudflare Workers
# -----------------------------------------------------------------

blog: https://www.aaronmsft.com/posts/static-sites-hugo-azure-cloudflare/

# 1. Hugo + Docker
# ----------------

docker build -t hugo .

docker run --rm -v `pwd`:/pwd/ -p 1313:1313/tcp -it hugo

cd /pwd/

hugo new site aaronmsft-com

cd /pwd/aaronmsft-com/themes/

git clone https://gitlab.com/beli3ver/hemingway2.git

git clone https://github.com/davidhampgonsalves/hugo-black-and-light-theme

cd /pwd/aaronmsft-com/

echo 'theme = "hemingway2"' >> config.toml

hugo new posts/hello-hugo.md

vi content/posts/hello-hugo.md

# I removed draft:true and added some content

cd /pwd/aaronmsft-com/

# test our site, view edits live
hugo server -D --bind "0.0.0.0"

# build site
hugo

# 2. Azure Blob Storage
# ---------------------

RESOURCE_GROUP='180300-static'
STORAGE_ACCOUNT='180300static' # this needs to be globally unique
STORAGE_CONTAINER='aaronmsft-com'

az group create -n $RESOURCE_GROUP -l eastus

az storage account create -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT \
    --location eastus --sku Standard_LRS

export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT | jq -r .connectionString)

cd aaronmsft-com/
# az storage blob delete-batch --source $STORAGE_CONTAINER
az storage blob upload-batch --source public/ --destination $STORAGE_CONTAINER