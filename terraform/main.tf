locals {
  base_name = lower(replace("${var.project_name}${var.owner_name}", "/[^a-z0-9]/", ""))
  database_name = "RabbitMqDemo"
  console_docker_image = "matthieuf/pubsub-console:1.0"
  api_docker_image = "matthieuf/pubsub-api:1.3"
  rabbitmq_docker_image = "rabbitmq:3-management"
}

resource "azurerm_container_group" "res-1" {
  location            = var.location
  name                = "${local.base_name}console"
  os_type             = "Linux"
  resource_group_name = data.azurerm_resource_group.res-0.name
  restart_policy      = "OnFailure"
  container {
    cpu = 1
    environment_variables = {
      RabbitMQ__Hostname = azurerm_container_group.res-2.ip_address
    }
    image  = local.console_docker_image
    memory = 1
    name   = "${local.base_name}console"
    secure_environment_variables = {
      RabbitMQ__Password = var.RabbitMQ-Password
      RabbitMQ__Username = var.RabbitMQ-Username
    }
  }
  diagnostics {
    log_analytics {
      log_type      = "ContainerInstanceLogs"
      workspace_id  = data.azurerm_log_analytics_workspace.res-3.workspace_id
      workspace_key = data.azurerm_log_analytics_workspace.res-3.primary_shared_key
    }
  }
}

resource "azurerm_container_group" "res-2" {
  location            = var.location
  name                = "${local.base_name}rbmq"
  os_type             = "Linux"
  resource_group_name = data.azurerm_resource_group.res-0.name
  restart_policy      = "OnFailure"
  container {
    cpu    = 1
    image  = local.rabbitmq_docker_image
    memory = 1
    name   = "${local.base_name}rbmq"
    secure_environment_variables = {
      RABBITMQ_DEFAULT_PASS = var.RabbitMQ-Password
      RABBITMQ_DEFAULT_USER = var.RabbitMQ-Username
    }
    ports {
      port = 15672
    }
    ports {
      port = 5672
    }
  }
  diagnostics {
    log_analytics {
      log_type      = "ContainerInstanceLogs"
      workspace_id  = data.azurerm_log_analytics_workspace.res-3.workspace_id
      workspace_key = data.azurerm_log_analytics_workspace.res-3.primary_shared_key
    }
  }
}

resource "azurerm_mssql_server" "res-607" {
  administrator_login = var.sql-server-username
  administrator_login_password = var.sql-server-password
  location            = var.location
  name                = "${local.base_name}sql"
  resource_group_name = data.azurerm_resource_group.res-0.name
  version             = "12.0"
}

resource "azurerm_mssql_database" "res-617" {
  name                 = local.database_name
  server_id            = azurerm_mssql_server.res-607.id
  storage_account_type = "Local"
  depends_on = [
    azurerm_mssql_server.res-607,
  ]
}

resource "azurerm_mssql_firewall_rule" "res-646" {
  end_ip_address   = "0.0.0.0"
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.res-607.id
  start_ip_address = "0.0.0.0"
  depends_on = [
    azurerm_mssql_server.res-607,
  ]
}

resource "azurerm_service_plan" "res-657" {
  location            = var.location
  name                = "${local.base_name}asp"
  os_type             = "Linux"
  resource_group_name = data.azurerm_resource_group.res-0.name
  sku_name            = "P0v3"
}

resource "azurerm_linux_web_app" "res-658" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.res-687.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    ApplicationInsights__ConnectionString      = azurerm_application_insights.res-687.connection_string
    ConnectionStrings__DefaultConnection       = "Server=tcp:${azurerm_mssql_server.res-607.fully_qualified_domain_name},1433;Initial Catalog=${local.database_name};Persist Security Info=False;User ID=${var.sql-server-username};Password=${var.sql-server-password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    RabbitMQ__Hostname                         = azurerm_container_group.res-2.ip_address
    RabbitMQ__Password                         = var.RabbitMQ-Password
    RabbitMQ__Username                         = var.RabbitMQ-Username
    XDT_MicrosoftApplicationInsights_Mode      = "Recommended"
  }
  https_only          = true
  location            = var.location
  name                = "${local.base_name}api"
  resource_group_name = data.azurerm_resource_group.res-0.name
  service_plan_id     = azurerm_service_plan.res-657.id
  site_config {
    ftps_state                        = "FtpsOnly"
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Allow"
  }
  depends_on = [
    azurerm_service_plan.res-657,
  ]
}

resource "azurerm_application_insights" "res-687" {
  application_type    = "web"
  location            = var.location
  name                = "${local.base_name}appi"
  resource_group_name = data.azurerm_resource_group.res-0.name
  sampling_percentage = 0
  workspace_id        = data.azurerm_log_analytics_workspace.res-3.id
}
