terraform {
  backend "azurerm" {
    use_azuread_auth = true
  }
}