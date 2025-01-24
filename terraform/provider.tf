terraform {

  backend "local" {
    path = "terraform.tfstate"
  }

  # Azure backend storage example
  # backend "azurerm" {
  #   resource_group_name   = "myResourceGroup"
  #   storage_account_name  = "mystorageaccount"
  #   container_name        = "tfstate"
  #   key                   = "terraform.tfstate"
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.99.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  use_oidc                   = false
  skip_provider_registration = true
  subscription_id            = ""
  environment                = "public"
  use_msi                    = false
  use_cli                    = true
}
