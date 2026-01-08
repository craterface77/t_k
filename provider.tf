terraform {
  required_version = ">= 1.0"

  required_providers {
    kaleido = {
      source  = "kaleido-io/kaleido"
      version = "~> 1.1.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# HashiCorp Vault Provider
provider "vault" {
  address = var.vault_address
  token   = var.vault_token

  # Skip TLS verification for dev vault (set to true for production)
  skip_tls_verify = var.vault_skip_tls_verify
}

# Kaleido Provider - uses credentials from Vault
provider "kaleido" {
  platform_api      = local.kaleido_credentials.api_endpoint
  platform_username = local.kaleido_credentials.username
  platform_password = local.kaleido_credentials.api_key
}

# Azure Provider (only needed if using Azure Key Vault remote signing)
# NOTE: This provider is always configured, but Azure resources are only created
# when key_manager_type = "AzureKeyVaultSigner" (via count in module)
#
# Authentication via environment variables (recommended for production):
# export ARM_SUBSCRIPTION_ID="your-azure-subscription-id"
# export ARM_TENANT_ID="your-azure-tenant-id"
# export ARM_CLIENT_ID="your-service-principal-client-id"
# export ARM_CLIENT_SECRET="your-service-principal-secret"
provider "azurerm" {
  features {}
}
