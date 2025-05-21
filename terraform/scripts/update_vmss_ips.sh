#!/bin/bash

RESOURCE_GROUP="chatbot-rg"
VMSS_NAME="custom-vmss"

instance_ids=$(az vmss list-instances \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VMSS_NAME" \
  --query "[].instanceId" -o tsv)

ips=()

for id in $instance_ids; do
  nic_id=$(az vmss nic list \
    --resource-group "$RESOURCE_GROUP" \
    --vmss-name "$VMSS_NAME" \
    --instance-id "$id" \
    --query "[0].id" -o tsv)

  ip=$(az network nic show \
    --ids "$nic_id" \
    --query "ipConfigurations[0].privateIpAddress" \
    -o tsv)

  # Only add non-empty IPs
  if [[ -n "$ip" ]]; then
    ips+=("\"$ip\"")
  fi
done

# Create terraform.tfvars.json with properly formatted array
cat <<EOF > terraform.tfvars.json
{
  "vmss_private_ips": [$(IFS=,; echo "${ips[*]}")]
}
EOF
