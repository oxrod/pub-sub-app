data "azurerm_resource_group" "res-0" {
  name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "res-3" {
  name = var.log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.res-0.name
}