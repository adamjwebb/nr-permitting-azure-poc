resource "random_password" "postgresql_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "postgresql_server" {
  source                        = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version                       = "0.1.4"
  name                          = "${local.abbrs.dBforPostgreSQLServers}${random_id.random_deployment_suffix.hex}"
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  server_version                = var.postgresql_version
  sku_name                      = var.postgresql_sku_name
  administrator_login           = var.postgresql_admin_username
  administrator_password        = random_password.postgresql_admin_password.result
  high_availability             = null
  zone                          = 1
  public_network_access_enabled = false
  private_endpoints = {
    primary = {
      name               = "${local.abbrs.privateEndpoint}${local.abbrs.dBforPostgreSQLServers}${random_id.random_deployment_suffix.hex}"
      subnet_resource_id = module.privateEndpoint_subnet.resource.id
    }
  }
  private_endpoints_manage_dns_zone_group = false
  diagnostic_settings = {
    diagnostic_settings = {
      name                  = "diagnostic_settings"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    } 
  }
}
