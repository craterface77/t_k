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
