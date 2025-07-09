/* variable "tenant_id" {
  description = "The Azure Active Directory tenant ID for OIDC authentication."
  type        = string
}

variable "client_id" {
  description = "The client ID of the Azure AD application for OIDC authentication."
  type        = string
} */
variable "subscription_id" {
  description = "(Required) The Azure Subscription ID where the self-hosted runners will be deployed."
  type        = string
}

variable "resource_group_location" {
  type        = string
  default     = "canadacentral"
  description = "Location for all resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

// network variables

variable "existing_virtual_network_resource_group_name" {
  type        = string
  description = "Resource group name of the existing virtual network."
}

variable "existing_virtual_network_name" {
  type        = string
  description = "Name of the existing virtual network."
}

variable "apim_subnet_prefix" {
  type        = string
  description = "The address prefix for the API Management subnet."
}

variable "app_service_subnet_prefix" {
  type        = string
  description = "The address prefix for the App Service subnet."
}

variable "privateendpoint_subnet_prefix" {
  type        = string
  description = "The address prefix for the Private Endpoint subnet."
}

// app service variables

variable "appserviceplan_sku_name" {
  type        = string
  default     = "P0v3"
  description = "The SKU name for the App Service Plan."
}

variable "appserviceplan_zone_redundant" {
  type        = bool
  default     = false
  description = "Whether the App Service Plan is zone redundant."
}

variable "appserviceplan_premium_auto_scale_enabled" {
  type        = bool
  default     = false
  description = "Whether the App Service Plan has premium auto-scaling enabled."
}

variable "appserviceplan_worker_count" {
  type        = number
  default     = 1
  description = "The number of workers for the App Service Plan."
}

variable "docker_registry_url" {
  type        = string
  description = "The URL of the Docker registry."
  default     = "https://mcr.microsoft.com"
}

variable "docker_image_name" {
  type        = string
  description = "The name of the Docker image."
  default     = "appsvc/staticsite:latest"
}

// api management variables

variable "apim_publisher_email" {
  type        = string
  default     = "test@contoso.com"
  description = "The email address of the owner of the API Management service."
}

variable "apim_publisher_name" {
  type        = string
  default     = "Contoso"
  description = "The name of the owner of the API Management service."
}

variable "apim_sku_name" {
  type        = string
  description = "The pricing tier of the API Management service."
  default     = "Developer_1" # Default to Developer_1 tier
  validation {
    condition     = contains(["Developer_1", "Standard_1", "Premium_1"], var.apim_sku_name)
    error_message = "The sku_name must be one of the following: Developer_1, Standard_1, Premium_1."
  }
}

variable "apim_virtual_network_type" {
  type        = string
  default     = "External"
  description = "The virtual network type of the API Management service."
  validation {
    condition     = contains(["External", "Internal", "None"], var.apim_virtual_network_type)
    error_message = "The virtual network type must be one of the following: External, Internal, None."
  }
}

variable "api_name" {
  type        = string
  description = "The name of the API in API Management."
  default     = "nr-permitting-api"
}

variable "api_display_name" {
  type        = string
  description = "The display name of the API in API Management."
  default     = "NR Permitting API"
}

variable "api_path" {
  type        = string
  description = "The path for the API in API Management."
  default     = "nr-permitting"
}

variable "api_revision" {
  type        = string
  description = "The revision of the API in API Management."
  default     = "1"
}

// PostgreSQL variables

variable "postgresql_admin_username" {
  type        = string
  default     = "pgsqladmin"
  description = "The administrator username for the PostgreSQL server."
  
}

variable "postgresql_version" {
  type        = string
  default     = "16"
  description = "The version of PostgreSQL to use."
}

variable "postgresql_sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "The SKU name for the PostgreSQL server."
}

variable "postgresql_port" {
  type        = number
  default     = 5432
  description = "The port for the PostgreSQL server."
}

variable "postgresql_database_name" {
  type        = string
  default     = "nr_permitting_db"
  description = "The name of the PostgreSQL database."
}