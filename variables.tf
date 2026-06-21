# -----------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set for each environment
# -----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.location))
    error_message = "Location must be a valid Azure region name (e.g., westeurope, eastus)"
  }
}

# -----------------------------------------------------------------------------
# OPTIONAL VARIABLES WITH DEFAULTS
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "devnews"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,10}$", var.project_name))
    error_message = "Project name must be 3-11 lowercase alphanumeric characters starting with a letter"
  }
}

variable "cost_center" {
  description = "Cost center for billing and tagging purposes"
  type        = string
  default     = "Engineering"
}

variable "repository_url" {
  description = "Source control repository URL for tagging"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# COSMOS DB CONFIGURATION
# -----------------------------------------------------------------------------

variable "cosmos_consistency_level" {
  description = "Cosmos DB consistency level"
  type        = string
  default     = "Session"

  validation {
    condition     = contains(["Strong", "BoundedStaleness", "Session", "ConsistentPrefix", "Eventual"], var.cosmos_consistency_level)
    error_message = "Must be a valid Cosmos DB consistency level"
  }
}

variable "cosmos_enable_serverless" {
  description = "Enable serverless mode for Cosmos DB (recommended for dev)"
  type        = bool
  default     = true
}

variable "cosmos_enable_free_tier" {
  description = "Enable free tier for Cosmos DB (only one per subscription)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# FUNCTION APP CONFIGURATION
# -----------------------------------------------------------------------------

variable "function_dotnet_version" {
  description = ".NET version for Function App"
  type        = string
  default     = "8.0"

  validation {
    condition     = contains(["6.0", "7.0", "8.0", "9.0", "10.0"], var.function_dotnet_version)
    error_message = "Must be a supported .NET version (6.0, 7.0, 8.0, 9.0, 10.0)"
  }
}

variable "function_tts_voice_name" {
  description = "Azure TTS voice name for video generation"
  type        = string
  default     = "en-US-AndrewMultilingualNeural"
}

variable "daily_pipeline_schedule" {
  description = "CRON expression for the daily news crawl pipeline (empty = disabled)"
  type        = string
  default     = ""
}

variable "function_always_on" {
  description = "Keep Function App always on (not applicable for Consumption plan)"
  type        = bool
  default     = false
}

variable "function_maximum_instance_count" {
  description = "Maximum scale-out instances for the Function App (Flex Consumption). Caps worst-case compute cost."
  type        = number
  default     = 40

  validation {
    condition     = var.function_maximum_instance_count >= 40 && var.function_maximum_instance_count <= 1000
    error_message = "Flex Consumption maximum_instance_count must be between 40 and 1000."
  }
}

# -----------------------------------------------------------------------------
# STATIC WEB APP CONFIGURATION
# -----------------------------------------------------------------------------

variable "custom_domain" {
  description = "Custom domain for the frontend (added to CORS allowed origins)"
  type        = string
  default     = ""
}

variable "static_web_app_location" {
  description = "Location for Static Web App (limited availability: westus2, centralus, eastus2, westeurope, eastasia)"
  type        = string
  default     = "westeurope"

  validation {
    condition     = contains(["westus2", "centralus", "eastus2", "westeurope", "eastasia"], var.static_web_app_location)
    error_message = "Static Web Apps are only available in: westus2, centralus, eastus2, westeurope, eastasia"
  }
}

variable "static_web_app_sku" {
  description = "SKU tier for Static Web App"
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku)
    error_message = "Must be Free or Standard"
  }
}

# -----------------------------------------------------------------------------
# SECURITY CONFIGURATION
# -----------------------------------------------------------------------------

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access resources (for dev environments)"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for enhanced security (recommended for prod)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# MONITORING CONFIGURATION
# -----------------------------------------------------------------------------

variable "log_retention_days" {
  description = "Number of days to retain logs in Application Insights"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days"
  }
}

variable "enable_application_insights" {
  description = "Enable Application Insights for monitoring"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# COST MANAGEMENT
# -----------------------------------------------------------------------------

variable "monthly_budget_amount" {
  description = "Monthly cost budget for the resource group, in the subscription's billing currency. Alerts only; does not cap spend."
  type        = number
  default     = 50
}

variable "budget_alert_emails" {
  description = "Email addresses notified on budget thresholds. Empty list disables the budget resource."
  type        = list(string)
  default     = []
}

variable "budget_start_date" {
  description = "Budget start date (first day of a month, RFC3339). Must be within the last 12 months."
  type        = string
  default     = "2026-06-01T00:00:00Z"
}
