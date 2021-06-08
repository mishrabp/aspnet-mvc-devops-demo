# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

terraform {
  backend "azurerm" {
    resource_group_name   = "terraformstoragergp"
    storage_account_name  = "terraformsabibhu2021"
    container_name        = "aspnet-mvc-devops-demo-terraform"
    key                   = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


#Define variables
variable "resource_group_name" {
    default = "#{ResourceGroup}#"
    description = "the name of the resource group"
}

variable "resource_group_location" {
    default = "#{Location}#"
    description = "the location of the resource group"
}

variable "app_service_plan_name" {
    default = "#{AppServicePlan}#"
    description = "the name of the app service plan"
}

variable "app_service_name_prefix" {
    default = "#{AppServicePrefix}#"
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

    kind = "Windows"
    reserved = false

    sku {
        tier = "Basic"
        size = "B1"
    }

}

#Creating an App Service for QA
resource "azurerm_app_service" "qa" {
    name = "${var.app_service_name_prefix}-qa"
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

#Creating an App Service for PROD
#resource "azurerm_app_service" "prod" {
#    name = "${var.app_service_name_prefix}-prod"
#    location = azurerm_resource_group.my.location
#    resource_group_name = azurerm_resource_group.my.name
#    app_service_plan_id = azurerm_app_service_plan.my.id 

#    site_config {
#        dotnet_framework_version = "v4.0"
#        scm_type                 = "LocalGit"
#    }
    
#    app_settings = {
#        "SOME_KEY" = "some-value"
#    }

#    connection_string {
#        name  = "Database"
#        type  = "SQLServer"
#        value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
#    }
#}

output "website_hostname-qa" {
    value = azurerm_app_service.qa.default_site_hostname
    description = "the hostname of the website"
}

#output "website_hostname-prod" {
#    value = azurerm_app_service.prod.default_site_hostname
#    description = "the hostname of the website"
#}
