# Create subnet in our cluster vnet
az network vnet subnet create -g dev_rg --vnet-name dev_vnet \
    -n linkSubnet \
    --address-prefixes 10.10.1.0/24 \
    --disable-private-link-service-network-policies true

    
# Create load balancer
az network lb create \
    --resource-group dev_rg \
    --name linkLoadBalancer \
    --sku Standard \
    --vnet-name dev_vnet \
    --subnet linkSubnet \
    --frontend-ip-name lbFrontend \
    --backend-pool-name lbBackendPool

# Create health probe
az network lb probe create \
    --resource-group dev_rg \
    --lb-name linkLoadBalancer \
    --name neo4jNodeHealth \
    --protocol tcp \
    --port 7474

# Create load balancer rule
az network lb rule create \
    --resource-group dev_rg \
    --lb-name linkLoadBalancer \
    --name boltRule \
    --protocol tcp \
    --frontend-port 7687 \
    --backend-port 7687 \
    --frontend-ip-name lbFrontend \
    --backend-pool-name lbBackendPool \
    --probe-name neo4jNodeHealth \
    --idle-timeout 15 \
    --enable-tcp-reset true

az network private-link-service create \
    --resource-group dev_rg \
    --name privateLinkService \
    --vnet-name dev_vnet \
    --subnet linkSubnet \
    --lb-name linkLoadBalancer \
    --lb-frontend-ip-configs lbFrontend \
    --location northeurope


# Create private endpoint
# -------------------------------


# Create subnet for private endpoint in our backend vnet
az network vnet subnet create -g dev_rg --vnet-name dev_backend_vnet \
    -n linkSubnet \
    --address-prefixes "10.10.1.0/24" \
    --disable-private-endpoint-network-policies true


export private_link_resource_id=$(az network private-link-service show \
    --name privateLinkService \
    --resource-group dev_rg \
    --query id \
    --output tsv)

az network private-endpoint create \
    --connection-name peToPlsConnection \
    --name privateEndpoint \
    --private-connection-resource-id $private_link_resource_id \
    --resource-group dev_rg \
    --subnet linkSubnet \
    --manual-request false \
    --vnet-name dev_backend_vnet 