# =============================================================================
# PRODUCTION ENVIRONMENT CONFIGURATION
# =============================================================================
# Usage: terraform plan -var-file="environments/prod.tfvars" -var="subscription_id=YOUR_SUB_ID"
# =============================================================================

environment = "prod"
location    = "norwayeast"

# Project settings
project_name   = "dewnews"
cost_center    = "Engineering"
repository_url = ""

# Cosmos DB - production configuration
cosmos_consistency_level = "Session"
cosmos_enable_serverless = false # Consider provisioned throughput for predictable costs
cosmos_enable_free_tier  = false # Free tier not recommended for production

# Function App
function_dotnet_version = "8.0"
function_always_on      = false # Not applicable for Consumption plan

# Static Web App - Standard for production features
static_web_app_sku = "Standard"

# Security - strict for production
allowed_ip_addresses     = []   # Empty = no IP restrictions (use private endpoints instead)
enable_private_endpoints = true # Enable for enhanced security

# Monitoring - extended retention for production
log_retention_days          = 90 # Longer retention for production troubleshooting
enable_application_insights = true
