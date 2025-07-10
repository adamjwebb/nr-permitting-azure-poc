include {
  path = find_in_parent_folders()
}

locals {
  app_env = get_env("app_env")
  vnet_resource_group_name = get_env("vnet_resource_group_name") # this is the resource group where the VNet exists and initial setup was done.

}

# Include the common terragrunt configuration for all modules
generate "tools_tfvars" {
  path              = "tools.auto.tfvars"
  if_exists         = "overwrite"
  disable_signature = true  
  contents          = <<-EOF
    resource_group_name = "${local.vnet_resource_group_name}"
    location = "Canada Central"
EOF
}

