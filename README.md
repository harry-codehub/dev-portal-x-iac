# Dev-News Infrastructure

Terraform infrastructure for the Dev-News serverless application on Azure.

## Architecture

```
┌─────────────────┐
│  Static Web App │ ──── Frontend (React/Vue/etc.)
│   (dev-news)    │
└────────┬────────┘
         │
         │ HTTPS/API calls
         │
┌────────▼────────┐
│  Function App   │ ──── Backend API (.NET 9)
│ (Flex Consump.) │
└───┬─────────┬───┘
    │         │
    │ Managed │ Managed
    │ Identity│ Identity
    │         │
┌───▼───┐ ┌───▼───────┐
│Key    │ │ Cosmos DB │ ──── Data Storage
│Vault  │ │ (SQL API) │
└───────┘ └───────────┘
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with appropriate permissions

## Quick Start

### 1. Authenticate with Azure

```powershell
az login
$env:TF_VAR_subscription_id = "your-subscription-id"
```

### 2. Initialize Terraform

```powershell
terraform init
```

### 3. Deploy Development Environment

```powershell
# Create dev workspace
terraform workspace new dev
terraform workspace select dev

# Preview changes
terraform plan -var-file="environments/dev.tfvars"

# Apply changes
terraform apply -var-file="environments/dev.tfvars"
```

### 4. Deploy Production Environment

```powershell
# Create prod workspace (separate state from dev)
terraform workspace new prod
terraform workspace select prod

# Deploy prod
terraform apply -var-file="environments/prod.tfvars"
```

## Managing Multiple Environments

**IMPORTANT:** Each environment needs its own workspace to avoid destroying one when deploying another.

### Switching Between Environments

```powershell
# List workspaces
terraform workspace list

# Switch to dev
terraform workspace select dev
terraform plan -var-file="environments/dev.tfvars"

# Switch to prod
terraform workspace select prod
terraform plan -var-file="environments/prod.tfvars"
```

### Always Match Workspace to tfvars

| Workspace | Var File |
|-----------|----------|
| `dev` | `environments/dev.tfvars` |
| `prod` | `environments/prod.tfvars` |

## Project Structure

```
.
├── main.tf                    # Resource definitions
├── variables.tf               # Input variables with validation
├── outputs.tf                 # Output values
├── providers.tf               # Azure provider configuration
├── versions.tf                # Terraform/provider versions
├── locals.tf                  # Local values and naming
├── terraform.tfvars.example   # Example variable values
├── environments/
│   ├── dev.tfvars             # Development configuration
│   └── prod.tfvars            # Production configuration
└── README.md
```

## Resources Created

| Resource | Dev | Prod |
|----------|-----|------|
| Resource Group | `rg-devnews-dev` | `rg-devnews-prod` |
| Cosmos DB | `cosmos-devnews-dev` | `cosmos-devnews-prod` |
| Function App | `func-devnews-api-dev` | `func-devnews-api-prod` |
| Static Web App | `stapp-devnews-dev` | `stapp-devnews-prod` |
| Key Vault | `kv-devnews-dev` | `kv-devnews-prod` |
| App Insights | `appi-devnews-dev` | `appi-devnews-prod` |
| Storage Account | `stdevnewsfuncdev` | `stdevnewsfuncprod` |

## Configuration

### Subscription ID

Pass via environment variable (don't commit to tfvars):

```powershell
$env:TF_VAR_subscription_id = "your-subscription-id"
```

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name (dev, prod) | Required |
| `location` | Azure region | `norwayeast` |
| `project_name` | Project name for resource naming | `devnews` |
| `cosmos_enable_serverless` | Use serverless Cosmos DB | `true` |
| `function_dotnet_version` | .NET version | `9.0` |
| `static_web_app_sku` | Static Web App tier | `Free` |

## Manual Configuration (Not Managed by Terraform)

These are set up once and ignored by Terraform:

- **Key Vault Secrets**: Create manually in Azure Portal
  - `AnthropicApiKey`
  - `CosmosDbEndpoint`
  - `CosmosDbKey`
- **Function App Settings**: Configure in Azure Portal or via az cli
- **Function App CORS**: Configure in Azure Portal
- **Static Web App Repository**: Link via Azure Portal or GitHub Actions

## Outputs

```powershell
# View all outputs
terraform output

# Get specific output
terraform output function_app_url
terraform output static_web_app_url
terraform output cosmos_db_endpoint
```

## Security Features

- **Managed Identities**: Function App uses system-assigned identity
- **RBAC Authorization**: Key Vault and Storage use Azure RBAC
- **TLS 1.2**: Enforced on all resources
- **Flex Consumption**: Serverless Function App with automatic scaling

## Common Commands

```powershell
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show

# List all resources in state
terraform state list

# Destroy environment (be careful!)
terraform workspace select dev
terraform destroy -var-file="environments/dev.tfvars"
```

## Importing Existing Resources

If resources already exist in Azure, import them:

```powershell
$sub = "your-subscription-id"

# Resource Group
terraform import -var-file="environments/dev.tfvars" azurerm_resource_group.main "/subscriptions/$sub/resourceGroups/rg-devnews-dev"

# Function App
terraform import -var-file="environments/dev.tfvars" azurerm_function_app_flex_consumption.api "/subscriptions/$sub/resourceGroups/rg-devnews-dev/providers/Microsoft.Web/sites/func-devnews-api-dev"

# Cosmos DB
terraform import -var-file="environments/dev.tfvars" azurerm_cosmosdb_account.main "/subscriptions/$sub/resourceGroups/rg-devnews-dev/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-devnews-dev"

# Key Vault
terraform import -var-file="environments/dev.tfvars" azurerm_key_vault.main "/subscriptions/$sub/resourceGroups/rg-devnews-dev/providers/Microsoft.KeyVault/vaults/kv-devnews-dev"

# Static Web App
terraform import -var-file="environments/dev.tfvars" azurerm_static_web_app.main "/subscriptions/$sub/resourceGroups/rg-devnews-dev/providers/Microsoft.Web/staticSites/stapp-devnews-dev"

# Storage Account
terraform import -var-file="environments/dev.tfvars" azurerm_storage_account.function "/subscriptions/$sub/resourceGroups/rg-devnews-dev/providers/Microsoft.Storage/storageAccounts/stdevnewsfuncdev"
```

## Troubleshooting

### "Key Vault soft-deleted"

```powershell
az keyvault purge --name kv-devnews-dev --location norwayeast
```

### "Cosmos DB name taken"

Cosmos DB names are globally unique. Change `project_name` variable.

### "Insufficient permissions"

Ensure your Azure account has Owner or Contributor role on the subscription.

### Workspace Issues

```powershell
# Check current workspace
terraform workspace show

# Make sure workspace matches your tfvars file!
terraform workspace select dev  # for dev.tfvars
terraform workspace select prod # for prod.tfvars
```

### Storage Authentication Error on Deploy

Grant the Function App access to storage:

```powershell
$principalId = az functionapp identity show --name func-devnews-api-dev --resource-group rg-devnews-dev --query principalId -o tsv

az role assignment create --assignee $principalId --role "Storage Blob Data Owner" --scope "/subscriptions/$sub/resourceGroups/rg-devnews-dev/providers/Microsoft.Storage/storageAccounts/stdevnewsfuncdev"
```

## License

MIT
