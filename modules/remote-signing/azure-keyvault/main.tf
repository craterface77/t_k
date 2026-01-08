# Azure Key Vault Remote Signing Module
# Provides external signing for blockchain transactions using Azure Key Vault

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data source for existing Key Vault
data "azurerm_key_vault" "signing" {
  count               = var.create_key_vault ? 0 : 1
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

# Create new Key Vault (optional)
resource "azurerm_key_vault" "signing" {
  count                      = var.create_key_vault ? 1 : 0
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 90
  purge_protection_enabled   = var.enable_purge_protection

  # Network ACLs
  network_acls {
    default_action = var.network_default_action
    bypass         = "AzureServices"

    # Allow Kaleido IP ranges if provided
    ip_rules = var.allowed_ip_ranges
  }

  tags = var.tags
}

# Access policy for Kaleido service principal
resource "azurerm_key_vault_access_policy" "kaleido" {
  key_vault_id = var.create_key_vault ? azurerm_key_vault.signing[0].id : data.azurerm_key_vault.signing[0].id
  tenant_id    = var.tenant_id
  object_id    = var.kaleido_service_principal_object_id

  key_permissions = [
    "Get",
    "List",
    "Sign",
    "Verify",
  ]

  secret_permissions = []
  certificate_permissions = []
}

# Create signing key
resource "azurerm_key_vault_key" "signing" {
  count        = var.create_signing_key ? 1 : 0
  name         = var.signing_key_name
  key_vault_id = var.create_key_vault ? azurerm_key_vault.signing[0].id : data.azurerm_key_vault.signing[0].id
  key_type     = var.key_type
  key_size     = var.key_size
  key_opts     = ["sign", "verify"]

  tags = merge(var.tags, {
    Purpose = "blockchain-signing"
  })

  depends_on = [
    azurerm_key_vault_access_policy.kaleido
  ]
}

# Output configuration for Kaleido Firefly Key Manager
locals {
  vault_url = var.create_key_vault ? azurerm_key_vault.signing[0].vault_uri : data.azurerm_key_vault.signing[0].vault_uri
  key_name  = var.create_signing_key ? azurerm_key_vault_key.signing[0].name : var.signing_key_name

  # Configuration for Kaleido Firefly Key Manager
  key_manager_config = {
    type     = "AzureKeyVaultSigner"
    vaultUrl = local.vault_url
    keyName  = local.key_name
    tenantId = var.tenant_id
    clientId = var.kaleido_service_principal_client_id
  }
}
