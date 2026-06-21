# =============================================================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# =============================================================================
# Usage: terraform plan -var-file="environments/dev.tfvars" -var="subscription_id=YOUR_SUB_ID"
# =============================================================================

environment = "dev"
location    = "norwayeast"

# Project settings
project_name   = "devnews"
cost_center    = "Engineering"
repository_url = ""

# Cosmos DB - optimized for development (cost-effective)
cosmos_consistency_level = "Session"
cosmos_enable_serverless = true  # Serverless = pay only for what you use
cosmos_enable_free_tier  = false # Set to true if not used elsewhere

# Function App
function_dotnet_version         = "10.0"
function_always_on              = false # Not applicable for Consumption plan
function_maximum_instance_count = 40    # Cap scale-out to bound worst-case cost

# Static Web App - Free tier for development
static_web_app_sku = "Free"

# Security - relaxed for development
allowed_ip_addresses     = []    # Add developer IPs if needed
enable_private_endpoints = false # No private endpoints for dev

# Monitoring
log_retention_days          = 30 # Minimum retention for dev
enable_application_insights = true

# Cost management - budget alert (set emails to enable)
monthly_budget_amount = 50
budget_alert_emails   = ["david.f.haland@gmail.com"]
