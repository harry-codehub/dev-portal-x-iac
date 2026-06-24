# DevNews Infrastructure

> Terraform infrastructure-as-code that provisions the Azure serverless platform for DevNews.

This repo provisions everything DevNews runs on in Azure: a Function App (Flex Consumption) for the backend API, Cosmos DB for data, a Static Web App for the frontend, plus Key Vault, Application Insights, Log Analytics, and Storage. Environments (dev/prod) are separated by var-files, state is kept in a remote Azure backend, and all deploys authenticate via OIDC.

Part of the **DevNews** product, alongside the backend API ([`dev-news`](https://github.com/Steinklo/dev-news)) and web frontend ([`dev-news-frontend`](https://github.com/Steinklo/dev-news-frontend)).

## Quick start

```bash
az login
export TF_VAR_subscription_id="<your-subscription-id>"

terraform init -backend-config="key=devnews-dev.tfstate"
terraform plan -var-file="environments/dev.tfvars"
```

`plan` prints the resource diff; `No changes` means infrastructure matches state. **Apply is normally done by CI** (see Contributing). First-time setup of the remote state backend is a one-off: `./scripts/bootstrap-state.sh --subscription-id <id>`.

## Prerequisites & configuration

| Requirement | Value |
|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | >= 1.5.0 |
| azurerm provider | ~> 4.14 (lockfile pins 4.57.0) |
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | `az login` |
| Subscription role | Owner / Contributor |

Environments are differentiated purely by `-var-file="environments/<env>.tfvars"` — no Terraform workspaces. `subscription_id` is supplied via `TF_VAR_subscription_id` (or OIDC in CI), never committed. See `terraform.tfvars.example` for the full variable list.

**Secrets:** never commit real values. `*.tfvars` (except `terraform.tfvars.example` and `environments/*.tfvars`) and all `*.tfstate` are gitignored. Function App settings are fully Terraform-managed; secret *values* (e.g. `AnthropicApiKey`, `CosmosDbKey`) must exist in Key Vault out-of-band and are referenced via `@Microsoft.KeyVault(...)`.

## Cosmos DB containers

The Cosmos SQL database `dev-news-db` holds three containers, all partitioned on `/Key` and defined in the `cosmos_containers` map in `locals.tf` (created via `for_each`):

| Container | Purpose |
|---|---|
| `news-items` | Curated, AI-scored news articles |
| `short-videos` | Daily video metadata |
| `text-posts` | Generated LinkedIn social posts |

## Links

- Backend — [`dev-news`](https://github.com/Steinklo/dev-news)
- Frontend — [`dev-news-frontend`](https://github.com/Steinklo/dev-news-frontend)
- Remote state — Azure Storage `sttfstatedevnews`, container `tfstate`, RG `rg-terraform-state`; one state file per env (`devnews-<env>.tfstate`)

## Contributing

Open a PR against `main`; CI runs `fmt`, `validate`, and `plan` for both dev and prod and posts the plan to the PR. Merging to `main` auto-applies **dev**; **prod** is applied via the manual `Deploy Prod` workflow, gated by the `production` GitHub environment.

## License

Released under the [MIT License](LICENSE).
