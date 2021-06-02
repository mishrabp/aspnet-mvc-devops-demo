# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


#Define variables
variable "resource_group_name" {
    default = "rg-tf-testing"
    description = "the name of the resource group"
}

variable "resource_group_location" {
    default = "westus"
    description = "the location of the resource group"
}

variable "app_service_plan_name" {
    default = "my-asp"
    description = "the name of the app service plan"
}

variable "app_service_name_prefix" {
    default = "__myappservice__"
    description = "begining part of the app service name"
}


#Creating a resource group
resource "azurerm_resource_group" "my" {
    name = var.resource_group_name
    location = var.resource_group_location
}

#Creating an App Service plan
resource "azurerm_app_service_plan" "my" {
    name = var.app_service_plan_name
    location = azurerm_resource_group.my.location
    resource_group_name = azurerm_resource_group.my.name

    kind = "Linux"
    reserved = true

    sku {
        tier = "Basic"
        size = "B1"
    }

}

#Creating an App Service
resource "azurerm_app_service" "my" {
    name = "${var.app_service_name_prefix}"
    location = azurerm_resource_group.my.location
    resource_group_name = azurerm_resource_group.my.name
    app_service_plan_id = azurerm_app_service_plan.my.id 

    site_config {
        dotnet_framework_version = "v4.0"
        scm_type                 = "LocalGit"
    }
    
    app_settings = {
        "SOME_KEY" = "some-value"
    }

    connection_string {
        name  = "Database"
        type  = "SQLServer"
        value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
    }
}

output "website_hostname" {
    value = azurerm_app_service.my.default_site_hostname
    description = "the hostname of the website"
}

