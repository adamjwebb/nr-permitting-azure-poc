module "apim" {
  source                    = "Azure/avm-res-apimanagement-service/azurerm"
  version                   = "0.0.2"
  name                      = "${local.abbrs.apiManagementService}${random_id.random_deployment_suffix.hex}"
  location                  = data.azurerm_resource_group.rg.location
  resource_group_name       = data.azurerm_resource_group.rg.name
  publisher_email           = var.apim_publisher_email
  publisher_name            = var.apim_publisher_name
  sku_name                  = var.apim_sku_name
  virtual_network_type      = var.apim_virtual_network_type
  virtual_network_subnet_id = module.apim_subnet.resource_id
  managed_identities = {
    system_assigned = true
  }
  diagnostic_settings = {
    diag = {
      name                  = "diagnostic-settings"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
}

resource "azurerm_api_management_api" "nr-permitting-api" {
  name                  = var.api_name
  api_management_name   = module.apim.name
  resource_group_name   = data.azurerm_resource_group.rg.name
  revision              = var.api_revision
  display_name          = var.api_display_name
  path                  = var.api_path
  protocols             = ["https"]
  service_url           = "https://${module.webapp.resource_uri}.azurewebsites.net"
  subscription_required = false
}