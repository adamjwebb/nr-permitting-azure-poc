data "azurerm_subscription" "current" {}

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

resource "random_string" "azurerm_api_management_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_role_assignment" "apim_servicebus_data_sender" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_api_management.apim.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_app_storage_blob_data_owner" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
}


resource "azurerm_role_assignment" "function_app_servicebus_queue_data_receiver" {
  scope                = azurerm_servicebus_queue.servicebus_queue.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_app_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
}

/* resource "azurerm_container_registry_task" "acr_task" {
  name                  = "tfex-acr-task-${random_string.azurerm_api_management_name.result}"
  container_registry_id = azurerm_container_registry.acr.id

  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = "https://github.com/adamjwebb/nr-permitting-azure-poc/blob/main/src/Dockerfile"
    context_access_token = " "
    image_names          = ["helloworld:{{.Run.ID}}"]
  }
  
}

resource "azurerm_container_registry_task_schedule_run_now" "example" {
  container_registry_task_id = azurerm_container_registry_task.acr_task.id
}

az acr build --registry $ACR_NAME --image helloacrtasks:v1 --file /path/to/Dockerfile /path/to/build/context. */

resource "azurerm_application_insights" "app_insights" {
  name                = "tfex-app-insights-${random_string.azurerm_api_management_name.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_monitor_diagnostic_setting" "function_app_diagnostics" {
  name               = "function_app_diagnostics"
  target_resource_id = azurerm_linux_function_app.function_app.id
log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  enabled_log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "example-logs-${random_string.azurerm_api_management_name.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}