provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    cosmosdb {
      prevent_data_loss_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}
