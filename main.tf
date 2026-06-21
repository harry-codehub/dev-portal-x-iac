# =============================================================================
# DEV-NEWS INFRASTRUCTURE
# Azure serverless architecture: Static Web App + Function App + Cosmos DB
# =============================================================================

# -----------------------------------------------------------------------------
# RESOURCE GROUP
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = local.resource_names.resource_group
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# KEY VAULT
# -----------------------------------------------------------------------------

resource "azurerm_key_vault" "main" {
  name                = local.resource_names.key_vault
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Security settings
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  rbac_authorization_enabled      = true
  purge_protection_enabled        = local.is_production
  soft_delete_retention_days      = 7

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = local.common_tags
}

# Grant Function App access to Key Vault secrets
resource "azurerm_role_assignment" "function_to_keyvault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_function_app_flex_consumption.api.identity[0].principal_id
}

# Grant Function App access to Storage for deployments
resource "azurerm_role_assignment" "function_to_storage" {
  scope                = azurerm_storage_account.function.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_function_app_flex_consumption.api.identity[0].principal_id
}

# -----------------------------------------------------------------------------
# LOG ANALYTICS WORKSPACE (for Application Insights)
# -----------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  count = var.enable_application_insights ? 1 : 0

  name                = local.resource_names.log_analytics
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# APPLICATION INSIGHTS
# -----------------------------------------------------------------------------

resource "azurerm_application_insights" "main" {
  count = var.enable_application_insights ? 1 : 0

  name                = local.resource_names.app_insights
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main[0].id
  application_type    = "web"

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# COSMOS DB ACCOUNT
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_account" "main" {
  name                = local.resource_names.cosmos_account
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # Enable free tier if specified (only one per subscription)
  free_tier_enabled = var.cosmos_enable_free_tier

  consistency_policy {
    consistency_level       = var.cosmos_consistency_level
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  # Enable serverless for dev environments (cost-effective)
  dynamic "capabilities" {
    for_each = var.cosmos_enable_serverless ? [1] : []
    content {
      name = "EnableServerless"
    }
  }

  # Continuous backup for data protection
  backup {
    type = "Continuous"
    tier = "Continuous7Days"
  }

  tags = local.common_tags

  lifecycle {
    prevent_destroy = false # Set to true for production via tfvars
    ignore_changes = [
      tags["CreatedDate"]
    ]
  }
}

# -----------------------------------------------------------------------------
# COSMOS DB DATABASE
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = local.resource_names.cosmos_database
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

# -----------------------------------------------------------------------------
# COSMOS DB CONTAINERS
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each = local.cosmos_containers

  name                = each.value.name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = [each.value.partition_key_path]

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }
  }

  lifecycle {
    ignore_changes = [indexing_policy]
  }
}

# -----------------------------------------------------------------------------
# STORAGE ACCOUNT FOR FUNCTION APP
# -----------------------------------------------------------------------------

resource "azurerm_storage_account" "function" {
  name                     = local.resource_names.function_storage
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = local.is_production ? "GRS" : "LRS"
  min_tls_version          = "TLS1_2"

  # Enable blob soft delete for data protection
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = local.common_tags
}

# Storage container for Function App deployments (required for Flex Consumption)
resource "azurerm_storage_container" "deployments" {
  name                  = "deployments"
  storage_account_id    = azurerm_storage_account.function.id
  container_access_type = "private"
}

# Storage containers for generated video assets
resource "azurerm_storage_container" "videos" {
  name                  = "videos"
  storage_account_id    = azurerm_storage_account.function.id
  container_access_type = "blob" # Public read for video serving
}

resource "azurerm_storage_container" "thumbnails" {
  name                  = "thumbnails"
  storage_account_id    = azurerm_storage_account.function.id
  container_access_type = "blob" # Public read for thumbnail serving
}

# -----------------------------------------------------------------------------
# APP SERVICE PLAN (Flex Consumption - serverless)
# -----------------------------------------------------------------------------

resource "azurerm_service_plan" "function" {
  name                = "asp-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "FC1" # Flex Consumption plan

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# FUNCTION APP (Flex Consumption - serverless)
# -----------------------------------------------------------------------------

resource "azurerm_function_app_flex_consumption" "api" {
  name                = local.resource_names.function_app
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.function.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.function.primary_blob_endpoint}${azurerm_storage_container.deployments.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.function.primary_access_key

  runtime_name    = "dotnet-isolated"
  runtime_version = var.function_dotnet_version

  # Cap scale-out to bound worst-case compute cost (denial-of-wallet protection)
  maximum_instance_count = var.function_maximum_instance_count

  # System-assigned managed identity for secure access to Cosmos DB and Key Vault
  identity {
    type = "SystemAssigned"
  }

  site_config {
    cors {
      allowed_origins = compact([
        "https://${azurerm_static_web_app.main.default_host_name}",
        var.custom_domain != "" ? "https://${var.custom_domain}" : ""
      ])
    }
  }

  app_settings = local.function_app_settings

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# COSMOS DB ROLE ASSIGNMENT FOR FUNCTION APP
# Grant Function App access to Cosmos DB using managed identity
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_role_assignment" "function_to_cosmos" {
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  # Built-in "Cosmos DB Built-in Data Contributor" role
  role_definition_id = "${azurerm_cosmosdb_account.main.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id       = azurerm_function_app_flex_consumption.api.identity[0].principal_id
  scope              = azurerm_cosmosdb_account.main.id
}

# -----------------------------------------------------------------------------
# STATIC WEB APP
# -----------------------------------------------------------------------------

resource "azurerm_static_web_app" "main" {
  name                = local.resource_names.static_web_app
  resource_group_name = azurerm_resource_group.main.name
  location            = var.static_web_app_location # Limited region availability
  sku_tier            = var.static_web_app_sku
  sku_size            = var.static_web_app_sku

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      repository_url,
      repository_branch
    ]
  }
}

# -----------------------------------------------------------------------------
# COST MANAGEMENT
# Monthly budget alert on the resource group. Notifies on actual + forecasted
# spend; created only when alert emails are provided. This alerts, it does not
# cap spend — the Function App scale-out cap above bounds the worst case.
# -----------------------------------------------------------------------------

resource "azurerm_consumption_budget_resource_group" "main" {
  count = length(var.budget_alert_emails) > 0 ? 1 : 0

  name              = "budget-${var.project_name}-${var.environment}"
  resource_group_id = azurerm_resource_group.main.id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.budget_alert_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.budget_alert_emails
  }
}
