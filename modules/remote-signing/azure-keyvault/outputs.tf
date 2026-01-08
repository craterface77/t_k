# Outputs for Azure Key Vault Remote Signing

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.signing[0].id : data.azurerm_key_vault.signing[0].id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = local.vault_url
}

output "signing_key_id" {
  description = "ID of the signing key"
  value       = var.create_signing_key ? azurerm_key_vault_key.signing[0].id : null
}

output "signing_key_name" {
  description = "Name of the signing key"
  value       = local.key_name
}

output "key_manager_config" {
  description = "Configuration object for Kaleido Firefly Key Manager"
  value       = local.key_manager_config
  sensitive   = true
}

output "key_manager_type" {
  description = "Key manager type for Firefly"
  value       = "AzureKeyVaultSigner"
}

# Configuration string for easy integration
output "firefly_key_manager_json" {
  description = "JSON configuration for Firefly Key Manager"
  value       = jsonencode(local.key_manager_config)
  sensitive   = true
}
