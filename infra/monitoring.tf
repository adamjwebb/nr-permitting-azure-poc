module "log_analytics_workspace" {
  source                                    = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version                                   = "0.4.2"
  location                                  = data.azurerm_resource_group.rg.location
  resource_group_name                       = data.azurerm_resource_group.rg.name
  name                = "${local.abbrs.operationalInsightsWorkspaces}${random_id.random_deployment_suffix.hex}"
  log_analytics_workspace_retention_in_days = 30
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
}