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

  # Cosmos DB containers configuration
  cosmos_containers = {
    news_items = {
      name               = "news-items"
      partition_key_path = "/Key"
      unique_keys        = []
    }
  }
}
