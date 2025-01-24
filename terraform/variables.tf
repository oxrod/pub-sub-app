variable "project_name" {
  description = "The name of the project. i.e maalsi-24-2"
  type        = string
}

variable "owner_name" {
  description = "The name of the owner. i.e student1"
  type        = string  
}

variable "resource_group_name" {
  description = "The name of the existing resource group"
  type        = string  
}

variable "log_analytics_workspace_name" {
  description = "The name of the existing log analytics workspace. i.e logsmaalsi242mfolabs"
  type        = string  
}

variable "location" {
  description = "The location of the resources. i.e uksouth"
  type        = string  
}

variable "RabbitMQ-Username" {
  description = "The username for RabbitMQ"
  type        = string
  sensitive = true
}

variable "RabbitMQ-Password" {
  description = "The password for RabbitMQ"
  type        = string
  sensitive = true  
}

variable "sql-server-username" {
  description = "The username for the SQL Server"
  type        = string
  sensitive = true  
}

variable "sql-server-password" {
  description = "The password for the SQL Server"
  type        = string
  sensitive = true  
}