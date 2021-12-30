terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  client_id = var.client_id
  client_secret = var.client_secret
  features {}
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "ejWinRG"
  location = "eastus"
}
# Create the Windows App Service Plan
resource "azurerm_app_service_plan" "winappserviceplan" {
  name                = "win-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}
# Create the web app, pass in the App Service Plan ID, and deploy code from a public GitHub repo
resource "azurerm_app_service" "ejBestWinWebApp" {
  name                = "ejBestWinWebApp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.winappserviceplan.id
  source_control {
    repo_url           = "https://github.com/ejbest/terraform-cloud-azure-bastion"
    branch             = "winapp"
    manual_integration = true
    use_mercurial      = false
  }
}
resource "azurerm_app_service_custom_hostname_binding" "ejBestWinHname" {
  hostname            = "winapp.waterskiingguy.com"
  app_service_name    = azurerm_app_service.ejBestWinWebApp.name
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_dns_cname_record" "ejBestWinCname" {
  name                = "winapp"
  zone_name           = "waterskiingguy.com"
  resource_group_name = "terraform-cloud-test"
  ttl                 = 3600
  record             = "ejBestWinWebApp.azurewebsites.net"
}
