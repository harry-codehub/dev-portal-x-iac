# =============================================================================
# DEW-NEWS INFRASTRUCTURE
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
  principal_id         = azurerm_linux_function_app.api.identity[0].principal_id
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

    excluded_path {
      path = "/\"_etag\"/?"
    }
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

# -----------------------------------------------------------------------------
# APP SERVICE PLAN (Consumption Y1 - serverless, pay-per-execution)
# -----------------------------------------------------------------------------

resource "azurerm_service_plan" "function" {
  name                = "asp-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan - serverless, scales to zero

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# FUNCTION APP (Consumption - serverless)
# -----------------------------------------------------------------------------

resource "azurerm_linux_function_app" "api" {
  name                       = local.resource_names.function_app
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  service_plan_id            = azurerm_service_plan.function.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  https_only = true

  # System-assigned managed identity for secure access to Cosmos DB and Key Vault
  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version              = var.function_dotnet_version
      use_dotnet_isolated_runtime = true
    }

    # CORS configuration - allow Static Web App
    cors {
      allowed_origins = [
        "https://${azurerm_static_web_app.main.default_host_name}"
      ]
      support_credentials = true
    }

    # Application Insights connection
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.main[0].connection_string : null
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.main[0].instrumentation_key : null

    # Security settings
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"  = "dotnet-isolated"
    "WEBSITE_RUN_FROM_PACKAGE"  = "1"
    "CosmosDB__AccountEndpoint" = azurerm_cosmosdb_account.main.endpoint
    "CosmosDB__DatabaseName"    = azurerm_cosmosdb_sql_database.main.name
    "KeyVault__Uri"             = azurerm_key_vault.main.vault_uri
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"],
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags["hidden-link: /app-insights-resource-id"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-conn-string"]
    ]
  }
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
  principal_id       = azurerm_linux_function_app.api.identity[0].principal_id
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
}
