# DevNews Infrastructure

Terraform infrastructure-as-code for the DevNews serverless application on Azure.

## Architecture

```
┌─────────────────┐
│  Static Web App │ ──── Frontend (Next.js static export)
│   (dev-news)    │
└────────┬────────┘
         │ HTTPS/API calls
┌────────▼────────┐
│  Function App   │ ──── Backend API (.NET 9 isolated)
│ (Flex Consump.) │
└───┬─────────┬───┘
    │         │
    │ Managed │ Managed Identity
    │ Identity│
┌───▼───┐ ┌───▼───────┐
│Key    │ │ Cosmos DB │ ──── Data Storage
│Vault  │ │ (SQL API) │
└───────┘ └───────────┘
```

## Resources Created

| Resource | Dev Example | Prod Example |
|---|---|---|
| Resource Group | `rg-devnews-dev` | `rg-devnews-prod` |
| Cosmos DB Account | `cosmos-devnews-dev` | `cosmos-devnews-prod` |
| Function App (Flex Consumption) | `func-devnews-api-dev` | `func-devnews-api-prod` |
| Static Web App | `stapp-devnews-dev` | `stapp-devnews-prod` |
| Key Vault | `kv-devnews-dev` | `kv-devnews-prod` |
| Application Insights | `appi-devnews-dev` | `appi-devnews-prod` |
| Storage Account | `stdevnewsfuncdev` | `stdevnewsfuncprod` |
| Log Analytics Workspace | `log-devnews-dev` | `log-devnews-prod` |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with Owner/Contributor role

## Quick Start

```bash
# 1. Authenticate
az login
export TF_VAR_subscription_id="your-subscription-id"

# 2. Initialize
terraform init

# 3. Select workspace (one per environment)
terraform workspace new dev    # First time only
terraform workspace select dev

# 4. Plan and apply
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

## Environment Management

Each environment uses a separate Terraform workspace. **Always match workspace to tfvars file.**

| Workspace | Var File |
|---|---|
| `dev` | `environments/dev.tfvars` |
| `prod` | `environments/prod.tfvars` |

```bash
# Switch environments
terraform workspace select prod
terraform plan -var-file="environments/prod.tfvars"
```

## Project Structure

```
├── main.tf                    # All resource definitions
├── variables.tf               # Input variables with validation
├── outputs.tf                 # Output values
├── providers.tf               # Azure provider configuration
├── versions.tf                # Terraform/provider version constraints
├── locals.tf                  # Local values, naming conventions, tags
├── terraform.tfvars.example   # Example variable values
└── environments/
    ├── dev.tfvars             # Development configuration
    └── prod.tfvars            # Production configuration
```

## Key Variables

| Variable | Description | Default |
|---|---|---|
| `subscription_id` | Azure subscription ID | Required (env var) |
| `environment` | `dev`, `staging`, or `prod` | Required |
| `location` | Azure region | Required |
| `project_name` | Resource naming prefix | `devnews` |
| `cosmos_enable_serverless` | Serverless Cosmos DB | `true` |
| `function_dotnet_version` | .NET version | `8.0` |
| `static_web_app_sku` | Free or Standard | `Free` |
| `enable_application_insights` | Enable monitoring | `true` |

## Security

- **Managed identities**: Function App uses system-assigned identity for Cosmos DB and Key Vault access
- **RBAC**: Key Vault uses Azure RBAC authorization (no access policies)
- **TLS 1.2**: Enforced on storage
- **Purge protection**: Enabled on Key Vault in production
- **Cosmos DB role assignment**: Built-in Data Contributor role via managed identity

## Manual Configuration (Not Managed by Terraform)

- **Key Vault Secrets**: `AnthropicApiKey`, `CosmosDbEndpoint`, `CosmosDbKey`
- **Function App Settings**: Configured in Azure Portal
- **Static Web App Repository**: Linked via Azure Portal or GitHub Actions

## Common Commands

```bash
terraform fmt -recursive       # Format
terraform validate             # Validate
terraform output               # Show all outputs
terraform state list           # List managed resources
terraform show                 # Show current state

# Destroy (careful!)
terraform workspace select dev
terraform destroy -var-file="environments/dev.tfvars"
```

## Troubleshooting

| Issue | Solution |
|---|---|
| Key Vault soft-deleted | `az keyvault purge --name kv-devnews-dev --location norwayeast` |
| Cosmos DB name taken | Change `project_name` variable (globally unique) |
| Insufficient permissions | Need Owner/Contributor role on subscription |
| Wrong workspace | `terraform workspace show` — must match your tfvars file |
