# CLAUDE.md

Terraform IaC provisioning DevNews's Azure serverless infrastructure (backend Function App, data stores, frontend host). Siblings: `dev-news` (backend), `dev-news-frontend` (frontend).

## Tech stack

- Terraform >= 1.5.0
- azurerm provider ~> 4.14 (lockfile pins 4.57.0)
- Remote state: Azure Storage backend with OIDC auth — RG `rg-terraform-state`, account `sttfstatedevnews`, container `tfstate`, key `devnews-<env>.tfstate`

## Commands

```bash
export TF_VAR_subscription_id="<id>"                         # or rely on OIDC in CI
terraform init -backend-config="key=devnews-dev.tfstate"     # per-env state key is REQUIRED
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/dev.tfvars"
terraform output
```

`apply` is done by CI, not locally — especially for prod. One-off backend setup: `./scripts/bootstrap-state.sh --subscription-id <id>`.

## Architecture & key patterns

- Flat root module — no submodules. Files: `main.tf` (all resources), `variables.tf` (with validation), `outputs.tf`, `locals.tf` (naming, tags, `function_app_settings`, `cosmos_containers`), `providers.tf`, `versions.tf`; `environments/*.tfvars`; `scripts/bootstrap-state.sh`; `.github/workflows/`.
- Resources: Resource Group, Key Vault (RBAC auth), Cosmos DB (account + database `dev-news-db` + containers `news-items`, `short-videos`), Function App (Flex Consumption `FC1`, `dotnet-isolated`), Static Web App, Application Insights + Log Analytics (conditional on `enable_application_insights`), Storage (containers `deployments`, `videos`, `thumbnails`).
- Auth: Function App system-assigned managed identity → Cosmos (Built-in Data Contributor), Key Vault (Secrets User), Storage (Blob Data Owner). No connection-string secrets in code.
- Function App settings fully Terraform-managed: non-secrets inline, secrets as `@Microsoft.KeyVault(SecretUri=...)` references. Secret *values* are created out-of-band, not by Terraform.

## Conventions

- Naming: `{type}-{project}-{env}` (e.g. `func-devnews-api-dev`); storage accounts have no hyphens (`st{project}func{env}`).
- Tags: every resource gets `Project`, `Environment`, `ManagedBy=Terraform`, `CostCenter`, `Repository` via `local.common_tags`.
- Environments via `-var-file` only — no workspaces. `subscription_id` via `TF_VAR_subscription_id` / `-var`, never in tfvars.
- Add Cosmos containers through the `cosmos_containers` map in `locals.tf` (`for_each`).
- Production guards keyed on `local.is_production`: Key Vault purge protection, GRS storage replication.

## Gotchas

- **Never `terraform apply` locally against prod.** Prod applies only via the manual `Deploy Prod` (`workflow_dispatch`) workflow, gated by the `production` GitHub environment. Dev auto-applies on merge to `main`.
- Always pass `-backend-config="key=devnews-<env>.tfstate"` on `init` — the key is not in `versions.tf`, so a bare `init` uses the wrong/empty state key.
- Never edit or commit state (`*.tfstate*` gitignored). Never commit real tfvars/secrets — only `terraform.tfvars.example` and `environments/*.tfvars` are tracked, and those must stay secret-free.
- Both env files pin `function_dotnet_version = "10.0"` (the variable default is `8.0`).
- Static Web App `location` is region-limited (e.g. westus2/centralus/eastus2/westeurope/eastasia).

## Further context

- `README.md` — onboarding and quick start. Siblings: [`dev-news`](https://github.com/Steinklo/dev-news), [`dev-news-frontend`](https://github.com/Steinklo/dev-news-frontend).
