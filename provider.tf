terraform {
  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "=3.45.0"
    }
  }
}

provider "azurerm" {
  features {}
}