#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Azure Storage for Terraform remote state.
# Run once before enabling the backend in versions.tf.
#
# Usage: ./scripts/bootstrap-state.sh --subscription-id <SUBSCRIPTION_ID>

RESOURCE_GROUP="rg-terraform-state"
LOCATION="norwayeast"
STORAGE_ACCOUNT="sttfstatedevnews"
CONTAINER="tfstate"

# Parse arguments
SUBSCRIPTION_ID=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --subscription-id) SUBSCRIPTION_ID="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "Error: --subscription-id is required"
  echo "Usage: $0 --subscription-id <SUBSCRIPTION_ID>"
  exit 1
fi

az account set --subscription "$SUBSCRIPTION_ID"

echo "Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

echo "Creating storage account: $STORAGE_ACCOUNT"
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none

echo "Creating blob container: $CONTAINER"
az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output none

echo ""
echo "Terraform state backend is ready."
echo "  Resource Group:  $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container:       $CONTAINER"
echo ""
echo "Next steps:"
echo "  1. Grant 'Storage Blob Data Contributor' to your OIDC service principals on this storage account"
echo "  2. Migrate local state: terraform init -migrate-state -backend-config=\"key=devnews-dev.tfstate\""
