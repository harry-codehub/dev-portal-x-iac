# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# =============================================================================
# Usage: terraform plan -var-file="environments/dev.tfvars"
# =============================================================================

environment = "dev"
location    = "norwayeast"

# Project settings
project_name   = "dewnews"
cost_center    = "Engineering"
repository_url = ""

# Cosmos DB - optimized for development (cost-effective)
cosmos_consistency_level = "Session"
cosmos_enable_serverless = true     # Serverless = pay only for what you use
cosmos_enable_free_tier  = false    # Set to true if not used elsewhere

# Function App
function_dotnet_version = "9.0"
function_always_on      = false     # Not applicable for Consumption plan

# Static Web App - Free tier for development
static_web_app_sku = "Free"

# Security - relaxed for development
allowed_ip_addresses     = []       # Add developer IPs if needed
enable_private_endpoints = false    # No private endpoints for dev

# Monitoring
log_retention_days          = 30    # Minimum retention for dev
enable_application_insights = true
