# Azure Key Vault Variables

variable "create_key_vault" {
  description = "Whether to create a new Key Vault or use existing one"
  type        = bool
  default     = false
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "location" {
  description = "Azure region for Key Vault"
  type        = string
  default     = "eastus"
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "sku_name" {
  description = "SKU name for Key Vault (standard or premium)"
  type        = string
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be either 'standard' or 'premium'. Use 'premium' for HSM-backed keys."
  }
}

variable "enable_purge_protection" {
  description = "Enable purge protection (cannot be disabled once enabled)"
  type        = bool
  default     = true
}

variable "network_default_action" {
  description = "Default network action for Key Vault access"
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "Network default action must be either 'Allow' or 'Deny'."
  }
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access Key Vault"
  type        = list(string)
  default     = []
}

# Kaleido Service Principal Configuration

variable "kaleido_service_principal_object_id" {
  description = "Azure AD object ID of the service principal used by Kaleido"
  type        = string
}

variable "kaleido_service_principal_client_id" {
  description = "Azure AD client ID (application ID) of the service principal"
  type        = string
}

# Signing Key Configuration

variable "create_signing_key" {
  description = "Whether to create a new signing key or use existing one"
  type        = bool
  default     = true
}

variable "signing_key_name" {
  description = "Name of the signing key in Key Vault"
  type        = string
  default     = "blockchain-signing-key"
}

variable "key_type" {
  description = "Type of key to create (EC or RSA). Use EC for blockchain signing."
  type        = string
  default     = "EC"

  validation {
    condition     = contains(["EC", "EC-HSM", "RSA", "RSA-HSM"], var.key_type)
    error_message = "Key type must be EC, EC-HSM, RSA, or RSA-HSM. EC-HSM recommended for production."
  }
}

variable "key_size" {
  description = "Size of the key. For EC: use P-256K (secp256k1) for Ethereum compatibility."
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 384, 521, 2048, 3072, 4096], var.key_size)
    error_message = "Key size must be 256, 384, 521 (for EC) or 2048, 3072, 4096 (for RSA)."
  }
}

# Tags

variable "tags" {
  description = "Tags to apply to Azure resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Purpose   = "blockchain-signing"
  }
}
