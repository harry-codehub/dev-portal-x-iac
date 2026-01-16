# =============================================================================
# OUTPUTS
# Important values for application configuration and deployment
# =============================================================================

# -----------------------------------------------------------------------------
# RESOURCE GROUP
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# -----------------------------------------------------------------------------
# COSMOS DB
# -----------------------------------------------------------------------------

output "cosmos_db_endpoint" {
  description = "Cosmos DB account endpoint"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_account_name" {
  description = "Cosmos DB account name"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmos_db_database_name" {
  description = "Cosmos DB database name"
  value       = azurerm_cosmosdb_sql_database.main.name
}

output "cosmos_db_primary_key" {
  description = "Cosmos DB primary key (use managed identity instead when possible)"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmos_db_connection_string" {
  description = "Cosmos DB primary connection string (use managed identity instead when possible)"
  value       = azurerm_cosmosdb_account.main.primary_sql_connection_string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# FUNCTION APP
# -----------------------------------------------------------------------------

output "function_app_name" {
  description = "Name of the Function App"
  value       = azurerm_function_app_flex_consumption.api.name
}

output "function_app_url" {
  description = "Default URL of the Function App"
  value       = "https://${azurerm_function_app_flex_consumption.api.default_hostname}"
}

output "function_app_principal_id" {
  description = "Principal ID of the Function App managed identity"
  value       = azurerm_function_app_flex_consumption.api.identity[0].principal_id
}

# -----------------------------------------------------------------------------
# STATIC WEB APP
# -----------------------------------------------------------------------------

output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = azurerm_static_web_app.main.name
}

output "static_web_app_url" {
  description = "Default URL of the Static Web App"
  value       = "https://${azurerm_static_web_app.main.default_host_name}"
}

output "static_web_app_api_key" {
  description = "API key for Static Web App deployments"
  value       = azurerm_static_web_app.main.api_key
  sensitive   = true
}

# -----------------------------------------------------------------------------
# KEY VAULT
# -----------------------------------------------------------------------------

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

# -----------------------------------------------------------------------------
# STORAGE
# -----------------------------------------------------------------------------

output "function_storage_account_name" {
  description = "Name of the storage account for Function App"
  value       = azurerm_storage_account.function.name
}

# -----------------------------------------------------------------------------
# MONITORING
# -----------------------------------------------------------------------------

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = var.enable_application_insights ? azurerm_application_insights.main[0].connection_string : null
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = var.enable_application_insights ? azurerm_application_insights.main[0].instrumentation_key : null
  sensitive   = true
}

# -----------------------------------------------------------------------------
# DEPLOYMENT HELPER OUTPUTS
# -----------------------------------------------------------------------------

output "deployment_info" {
  description = "Summary of deployed infrastructure"
  value = {
    environment        = var.environment
    location           = var.location
    static_web_app_url = "https://${azurerm_static_web_app.main.default_host_name}"
    function_app_url   = "https://${azurerm_function_app_flex_consumption.api.default_hostname}"
    cosmos_endpoint    = azurerm_cosmosdb_account.main.endpoint
    key_vault_uri      = azurerm_key_vault.main.vault_uri
  }
}
