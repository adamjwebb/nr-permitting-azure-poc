module "key_vault" {
  source                        = "Azure/avm-res-keyvault-vault/azurerm"
  version                       = "0.10.0"
  name                          = "${local.abbrs.keyVaultVaults}${random_id.random_deployment_suffix.hex}"
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = false
  network_acls                  = null
  private_endpoints = {
    primary = {
      name               = "${local.abbrs.privateEndpoint}${local.abbrs.keyVaultVaults}${random_id.random_deployment_suffix.hex}"
      subnet_resource_id = module.privateEndpoint_subnet.resource.id
    }
  }
  private_endpoints_manage_dns_zone_group = false
/*   role_assignments = {
    secrets_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = module.webapp.identity_principal_id
    }
  } */
  secrets       = {}
  secrets_value = {}
  diagnostic_settings = {
    diagnostic_settings = {
      name                  = "diagnostic_settings"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  depends_on = [ module.webapp ]
}
