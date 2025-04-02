terraform {

    required_version = ">= 1.5.0"

    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "3.83.0"
        }
    }

    backend "azurerm" {
        resource_group_name  = "rg-aks-arc"
        storage_account_name = "tfstoragerjp"
        container_name       = "tf-state-test"
        key                  = "k8s-tf-test.tfstate"
        use_oidc             = true
    }
}

provider "azurerm" {
    use_oidc = true
}