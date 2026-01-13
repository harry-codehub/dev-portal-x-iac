# Dew-News Infrastructure

Terraform infrastructure for the Dew-News serverless application on Azure.

## Architecture

```
┌─────────────────┐
│  Static Web App │ ──── Frontend (React/Vue/etc.)
│   (dew-news)    │
└────────┬────────┘
         │
         │ HTTPS/API calls
         │
┌────────▼────────┐
│  Function App   │ ──── Backend API (.NET 9)
│ (Consumption)   │
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

```bash
az login
az account set --subscription "Your Subscription Name"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Deploy Development Environment

```bash
# Preview changes
terraform plan -var-file="environments/dev.tfvars"

# Apply changes
terraform apply -var-file="environments/dev.tfvars"
```

### 4. Deploy Production Environment

For production, use a separate state file or workspace:

```bash
# Option A: Using workspaces
terraform workspace new prod
terraform apply -var-file="environments/prod.tfvars"

# Option B: Using separate state (recommended)
# Configure backend in versions.tf with different key per environment
```

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
| Resource Group | `rg-dewnews-dev` | `rg-dewnews-prod` |
| Cosmos DB | `cosmos-dewnews-dev` (serverless) | `cosmos-dewnews-prod` (provisioned) |
| Function App | `func-dewnews-api-dev` | `func-dewnews-api-prod` |
| Static Web App | `stapp-dewnews-dev` (Free) | `stapp-dewnews-prod` (Standard) |
| Key Vault | `kv-dewnews-dev` | `kv-dewnews-prod` |
| App Insights | `appi-dewnews-dev` | `appi-dewnews-prod` |
| Storage Account | `stdewnewsfuncdev` | `stdewnewsfuncprod` |

## Configuration

### Environment Variables

Copy `terraform.tfvars.example` to customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name (dev, staging, prod) | Required |
| `location` | Azure region | Required |
| `project_name` | Project name for resource naming | `dewnews` |
| `cosmos_enable_serverless` | Use serverless Cosmos DB | `true` |
| `function_dotnet_version` | .NET version | `8.0` |
| `static_web_app_sku` | Static Web App tier | `Free` |

## Outputs

After deployment, Terraform outputs important values:

```bash
# View all outputs
terraform output

# Get specific output
terraform output function_app_url
terraform output static_web_app_url
terraform output cosmos_db_endpoint

# Get sensitive outputs
terraform output -raw static_web_app_api_key
```

### Key Outputs

- `static_web_app_url` - Frontend URL
- `function_app_url` - API endpoint
- `cosmos_db_endpoint` - Database endpoint
- `key_vault_uri` - Key Vault URI
- `static_web_app_api_key` - Deployment token (sensitive)

## Security Features

- **Managed Identities**: Function App uses system-assigned identity
- **No Connection Strings**: Cosmos DB and Key Vault accessed via RBAC
- **RBAC Authorization**: Key Vault uses Azure RBAC (no access policies)
- **TLS 1.2**: Enforced on all resources
- **Purge Protection**: Enabled on Key Vault in production

## Environment Differences

| Setting | Dev | Prod |
|---------|-----|------|
| Cosmos DB Mode | Serverless | Provisioned |
| Static Web App | Free tier | Standard tier |
| Key Vault Purge Protection | Disabled | Enabled |
| Log Retention | 30 days | 90 days |
| Storage Replication | LRS | GRS |

## Common Commands

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show

# Destroy infrastructure
terraform destroy -var-file="environments/dev.tfvars"

# Import existing resource
terraform import -var-file="environments/dev.tfvars" \
  azurerm_resource_group.main /subscriptions/.../resourceGroups/rg-dewnews-dev
```

## Remote State (Recommended for Teams)

Uncomment and configure the backend in `versions.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatedewnews"
    container_name       = "tfstate"
    key                  = "dewnews-dev.tfstate"  # Use different key per env
  }
}
```

Create the storage account first:

```bash
# Create resource group for state
az group create --name rg-terraform-state --location norwayeast

# Create storage account
az storage account create \
  --name sttfstatedewnews \
  --resource-group rg-terraform-state \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name sttfstatedewnews
```

## Connecting Your Application

### Function App Configuration

The Function App receives these app settings automatically:

```
CosmosDB__AccountEndpoint = https://cosmos-dewnews-{env}.documents.azure.com:443/
CosmosDB__DatabaseName    = dew-news-db
KeyVault__Uri             = https://kv-dewnews-{env}.vault.azure.net/
```

### .NET Code Example

```csharp
// Use DefaultAzureCredential for managed identity
var credential = new DefaultAzureCredential();

// Cosmos DB
var cosmosClient = new CosmosClient(
    Environment.GetEnvironmentVariable("CosmosDB__AccountEndpoint"),
    credential
);

// Key Vault
var secretClient = new SecretClient(
    new Uri(Environment.GetEnvironmentVariable("KeyVault__Uri")),
    credential
);
```

## Troubleshooting

### Common Issues

1. **"Key Vault soft-deleted"**: A Key Vault with the same name was recently deleted
   ```bash
   az keyvault purge --name kv-dewnews-dev --location norwayeast
   ```

2. **"Cosmos DB name taken"**: Cosmos DB names are globally unique
   - Change `project_name` variable to something unique

3. **"Insufficient permissions"**: Ensure your Azure account has Owner or Contributor role

### Useful Commands

```bash
# Check Azure login
az account show

# List resource groups
az group list --query "[?contains(name,'dewnews')]" -o table

# Check Function App logs
az webapp log tail --name func-dewnews-api-dev --resource-group rg-dewnews-dev
```

## License

MIT
