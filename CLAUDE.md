# DevNews Infrastructure

Terraform IaC for the DevNews AI developer news aggregator on Azure. Provisions: Resource Group, Cosmos DB (serverless), Function App (Flex Consumption, .NET 9), Static Web App, Key Vault, Application Insights, Log Analytics, Storage Account.

## Commands

```bash
terraform init                                        # Initialize
terraform fmt -recursive                              # Format
terraform validate                                    # Validate
terraform plan -var-file="environments/dev.tfvars"    # Plan
terraform apply -var-file="environments/dev.tfvars"   # Apply
terraform output                                      # Show outputs
```

Set subscription: `export TF_VAR_subscription_id="..."`

## Project Structure

```
main.tf           # All resources (resource group, key vault, cosmos, function app, static web app, etc.)
variables.tf      # Input variables with validation rules
outputs.tf        # Output values (URLs, endpoints, IDs)
providers.tf      # Azure provider config
versions.tf       # Version constraints (Terraform >= 1.5, azurerm)
locals.tf         # Naming conventions, common tags, environment flags
environments/     # Per-environment tfvars (dev.tfvars, prod.tfvars)
```

## Environment Management

- One Terraform **workspace** per environment — always match workspace to tfvars file
- `terraform workspace select dev` + `-var-file="environments/dev.tfvars"`
- `terraform workspace select prod` + `-var-file="environments/prod.tfvars"`

## Key Conventions

- **Naming**: `{type}-{project}-{purpose}-{env}` (e.g., `func-devnews-api-dev`)
- **Storage accounts**: No hyphens (e.g., `stdevnewsfuncdev`)
- **Tags**: All resources get `Project`, `Environment`, `ManagedBy=Terraform`, `CostCenter`
- **Security**: Managed identities for Function→CosmosDB and Function→KeyVault (RBAC, no connection strings)
- **Function App lifecycle**: `ignore_changes = all` — app settings managed in Azure Portal
- **Cosmos containers**: Defined in `locals.tf` via `cosmos_containers` map, created with `for_each`
- **Production guards**: Purge protection on Key Vault, GRS storage replication
- **Application Insights**: Conditionally created via `enable_application_insights` variable
