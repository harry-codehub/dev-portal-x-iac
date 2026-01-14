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

variable "function_always_on" {
  description = "Keep Function App always on (not applicable for Consumption plan)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# STATIC WEB APP CONFIGURATION
# -----------------------------------------------------------------------------

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
