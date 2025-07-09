module "appserviceplan" {
  source                          = "Azure/avm-res-web-serverfarm/azurerm"
  version                         = "0.7.0"
  name                            = "${local.abbrs.webServerFarms}${random_id.random_deployment_suffix.hex}"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  os_type                         = "Linux"
  sku_name                        = var.appserviceplan_sku_name
  zone_balancing_enabled          = var.appserviceplan_zone_redundant
  premium_plan_auto_scale_enabled = var.appserviceplan_premium_auto_scale_enabled
  worker_count                    = var.appserviceplan_worker_count
  
}

module "webapp" {
  source                    = "Azure/avm-res-web-site/azurerm"
  version                   = "0.17.2"
  name                      = "${local.abbrs.webSitesAppService}${random_id.random_deployment_suffix.hex}"
  location                  = data.azurerm_resource_group.rg.location
  resource_group_name       = data.azurerm_resource_group.rg.name
  kind                      = "webapp"
  os_type                   = module.appserviceplan.resource.os_type
  service_plan_resource_id  = module.appserviceplan.resource.id
  virtual_network_subnet_id = module.app_service_subnet.resource.id
  public_network_access_enabled = false
  https_only = true
  managed_identities = {
    system_assigned = true
  }
//  key_vault_reference_identity_id = module.webapp.output.identity_principal_id
  private_endpoints = {
    primary = {
      name               = "${local.abbrs.privateEndpoint}${local.abbrs.webSitesAppService}${random_id.random_deployment_suffix.hex}"
      subnet_resource_id = module.privateEndpoint_subnet.resource.id
    }
  }

  site_config = {
    application_stack = {
      docker = {
        docker_registry_url = var.docker_registry_url
        docker_image_name   = var.docker_image_name
      }
    }
    minimum_tls_version = "1.2" # Required for current compatibility with APIM that uses TLS 1.2 for outbound connections
  }
  app_settings = {
    "DB_HOST"     = module.postgresql_server.fqdn
    "DB_PORT"     = var.postgresql_port
    "DB_NAME"     = var.postgresql_database_name
    "DB_USER"     = var.postgresql_admin_username
    "DB_PASSWORD" = random_password.postgresql_admin_password.result
    "DB_SSL"      = "true"
  }
  application_insights = {
    workspace_resource_id = module.log_analytics_workspace.resource_id
  }
    diagnostic_settings = {
    diagnostic_settings = {
      name                  = "diagnostic_settings"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
}

