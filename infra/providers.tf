terraform {
  required_version = ">= 1.9.0"

  backend "local" {}

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