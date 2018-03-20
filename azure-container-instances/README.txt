# Azure Container Instances (ACI) across 3 regions in under 30 seconds with Azure Traffic Manager
# -----------------------------------------------------------------------------------------------

blog: http://www.aaronmsft.com/posts/azure-container-instances/


# 1. deploy
# ---------

RESOURCE_GROUP='180300-aci'
PROFILE_NAME='180300-traffic-manager'
CONTAINER_NAME='container-1'
DNS_SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 5 ; echo)
DNS_NAME='180300-traffic-manager-'$DNS_SUFFIX
LOCATION='eastus'

az group create -n $RESOURCE_GROUP -l $LOCATION

az network traffic-manager profile create --name $PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --routing-method Weighted \
    --unique-dns-name $DNS_NAME \
    --monitor-path / \
    --monitor-port 80 \
    --monitor-protocol HTTP \
    --status Enabled \
    --ttl 10 

array=(
    'container-1::eastus'
    'container-2::westus'
    'container-3::westeurope'
)

for index in "${array[@]}" ; do
    CONTAINER_NAME="${index%%::*}"
    LOCATION="${index##*::}"

    az container delete -y -g $RESOURCE_GROUP -n $CONTAINER_NAME

    az container create -g $RESOURCE_GROUP -n $CONTAINER_NAME -l $LOCATION \
        --cpu 1 \
        --memory 1 \
        --ip-address public \
        --image hashicorp/http-echo \
        --command-line '/http-echo -text "'$CONTAINER_NAME'" -listen :80' \
        --dns-name-label $CONTAINER_NAME'-'$DNS_SUFFIX

    CONTAINER_FQDN=$(az container show -g $RESOURCE_GROUP -n $CONTAINER_NAME | jq -r .ipAddress.fqdn)

    az network traffic-manager endpoint create -g $RESOURCE_GROUP -n $CONTAINER_NAME \
        --profile-name $PROFILE_NAME \
        --type externalEndpoints \
        --weight 1 \
        --target $CONTAINER_FQDN

done


# 2. test
# -------

# curl
echo 'http://'$DNS_NAME'.trafficmanager.net/'
while true; do
    curl --connect-timeout 1 'http://'$DNS_NAME'.trafficmanager.net/'
    sleep 1
done

# dig + curl
# name server sourced via: dig +short trafficmanager.net NS
while true; do
    CONTAINER_HOST=$(dig +short @tm1.msft.net $DNS_NAME'.trafficmanager.net' | sed -e 's/\.$//')
    curl --connect-timeout 1 'http://'$CONTAINER_HOST'/'
    sleep 1
done
