terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    resource_group_name  = var.terraform_state_rg
    storage_account_name = var.terraform_state_storage
    container_name       = var.terraform_state_container
    key                  = "${var.environment}.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.32.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}
provider "azurerm" {
  use_oidc = true
  features {}
}