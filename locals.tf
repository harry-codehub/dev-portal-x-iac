# -----------------------------------------------------------------------------
# LOCAL VALUES
# Centralized naming conventions and common configurations
# -----------------------------------------------------------------------------

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "dev-news"
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
    Repository  = var.repository_url
  }

  # Resource naming convention: {type}-{project}-{purpose}-{environment}
  resource_names = {
    resource_group   = "rg-${var.project_name}-${var.environment}"
    cosmos_account   = "cosmos-${var.project_name}-${var.environment}"
    cosmos_database  = "dev-news-db"
    function_app     = "func-${var.project_name}-api-${var.environment}"
    function_storage = "st${var.project_name}func${var.environment}"
    static_web_app   = "stapp-${var.project_name}-${var.environment}"
    app_insights     = "appi-${var.project_name}-${var.environment}"
    log_analytics    = "log-${var.project_name}-${var.environment}"
    key_vault        = "kv-${var.project_name}-${var.environment}"
  }

  # Environment-specific configurations
  is_production = var.environment == "prod"

  # Key Vault reference helper
  kv_ref = "https://${local.resource_names.key_vault}.vault.azure.net/secrets"

  # Function App settings — secrets via Key Vault references, non-secrets from Terraform
  function_app_settings = {
    # Non-secret values from Terraform
    "CosmosDbEndpoint"                      = azurerm_cosmosdb_account.main.endpoint
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.enable_application_insights ? azurerm_application_insights.main[0].connection_string : ""

    # Key Vault references
    "CosmosDbKey"                            = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/CosmosDbKey)"
    "AzureStorageConnectionString"           = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/AzureStorageConnectionString)"
    "AnthropicApiKey"                        = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/AnthropicApiKey)"
    "CreatomateApiKey"                       = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/CreatomateApiKey)"
    "YouTubeClientId"                        = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/YouTubeClientId)"
    "YouTubeClientSecret"                    = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/YouTubeClientSecret)"
    "YouTubeRefreshToken"                    = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/YouTubeRefreshToken)"
    "LinkedInAccessToken"                    = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/LinkedInAccessToken)"
    "VideoGeneration:LinkedInOrganizationId" = "@Microsoft.KeyVault(SecretUri=${local.kv_ref}/VideoGenerationLinkedInOrganizationId)"

    # Plain configuration values
    "VideoGeneration:TtsVoiceName" = var.function_tts_voice_name
    "DailyPipelineSchedule"        = var.daily_pipeline_schedule != "" ? var.daily_pipeline_schedule : null
  }

  # Cosmos DB containers configuration
  cosmos_containers = {
    news_items = {
      name               = "news-items"
      partition_key_path = "/Key"
      unique_keys        = []
    }
    short_videos = {
      name               = "short-videos"
      partition_key_path = "/Key"
      unique_keys        = []
    }
  }
}
