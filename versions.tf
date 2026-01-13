terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }
  }

  # Uncomment and configure for remote state (recommended for team use)
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "sttfstatedewnews"
  #   container_name       = "tfstate"
  #   key                  = "dewnews.tfstate"
  # }
}
