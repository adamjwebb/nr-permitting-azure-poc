module "apim_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.9.0"

  virtual_network = {
    resource_id = data.azurerm_virtual_network.vnet.id
  }
  name             = "${local.abbrs.networkVirtualNetworksSubnets}apim-${random_id.random_deployment_suffix.hex}"
  address_prefixes = ["${var.apim_subnet_prefix}"]
  network_security_group = {
    id = module.apim_nsg.resource_id
  }
  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.EventHub"]
}

module "apim_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  name                = "${local.abbrs.networkNetworkSecurityGroups}apim-${random_id.random_deployment_suffix.hex}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  security_rules      = local.apim_nsg_security_rules
}

module "app_service_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.9.0"

  virtual_network = {
    resource_id = data.azurerm_virtual_network.vnet.id
  }
  name             = "${local.abbrs.networkVirtualNetworksSubnets}appservice-${random_id.random_deployment_suffix.hex}"
  address_prefixes = ["${var.app_service_subnet_prefix}"]
  network_security_group = {
    id = module.app_service_nsg.resource_id
  }
  delegation = [{
    name = "Microsoft.Web.serverFarms"
    service_delegation = {
      name = "Microsoft.Web/serverFarms"
    }
  }]
}

module "app_service_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  name                = "${local.abbrs.networkNetworkSecurityGroups}appservice-${random_id.random_deployment_suffix.hex}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  security_rules      = local.app_service_nsg_security_rules
}

module "privateEndpoint_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.9.0"

  virtual_network = {
    resource_id = data.azurerm_virtual_network.vnet.id
  }
  name             = "${local.abbrs.networkVirtualNetworksSubnets}privateendpoints-${random_id.random_deployment_suffix.hex}"
  address_prefixes = ["${var.privateendpoint_subnet_prefix}"]
  network_security_group = {
    id = module.privateEndpoint_nsg.resource_id
  }
}

module "privateEndpoint_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  name                = "${local.abbrs.networkNetworkSecurityGroups}privateendpoints-${random_id.random_deployment_suffix.hex}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  security_rules      = local.privateEndpoint_nsg_security_rules
}

module "apim_route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"

  name                = "${local.abbrs.networkRouteTables}apim-${random_id.random_deployment_suffix.hex}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  routes = {
    ApimMgmtEndpointToApimServiceTag = {
        name                   = "ApimMgmtEndpointToApimServiceTag"
        address_prefix         = "ApiManagement"
        next_hop_type          = "Internet"
      }
      ApimToInternet = {
    name                   = "ApimToInternet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }
  }
  subnet_resource_ids = {
    apimSubnet = module.apim_subnet.resource_id
  }
}
