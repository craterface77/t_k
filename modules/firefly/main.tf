
# Hyperledger Firefly Middleware Stack

# Create Stack for Firefly Middleware
resource "kaleido_platform_stack" "firefly_stack" {
  environment = var.environment_id
  name        = var.firefly_stack_name
  type        = "web3_middleware"
}


# Key Manager

# Must be created FIRST as other services depend on it

resource "kaleido_platform_runtime" "key_manager_runtime" {
  count       = var.enable_key_manager ? 1 : 0
  type        = "KeyManager"
  name        = var.key_manager_name
  environment = var.environment_id
  config_json = jsonencode(merge(
    {
      type = var.key_manager_type
    },
    { for k, v in var.key_manager_config : k => v if v != null }
  ))
}

resource "kaleido_platform_service" "key_manager_service" {
  count       = var.enable_key_manager ? 1 : 0
  type        = "KeyManager"
  name        = var.key_manager_name
  environment = var.environment_id
  runtime     = kaleido_platform_runtime.key_manager_runtime[0].id
  config_json = jsonencode({})
}

# Create wallet for Firefly
# Wallet is ALWAYS created, but type changes based on key manager type

locals {
  # Map key manager type to wallet type (per Kaleido documentation)
  wallet_type_map = {
    "HDWalletSigner"      = "hdwallet"
    "FireFlySigner"       = "hdwallet"
    "AzureKeyVaultSigner" = "azurekeyvault"
  }

  wallet_type = lookup(local.wallet_type_map, var.key_manager_type, "hdwallet")

  # Only create keys for local key managers (not for remote signers)
  is_local_key_manager = contains(["HDWalletSigner", "FireFlySigner"], var.key_manager_type)

  # For Azure Key Vault, extract config and creds
  is_azure_keyvault = var.key_manager_type == "AzureKeyVaultSigner"
}

resource "kaleido_platform_kms_wallet" "firefly_wallet" {
  count       = var.enable_key_manager ? 1 : 0
  type        = local.wallet_type
  name        = "firefly_wallet"
  environment = var.environment_id
  service     = kaleido_platform_service.key_manager_service[0].id

  # Configuration JSON - for Azure Key Vault includes vaultUrl, keyName, etc.
  config_json = local.is_azure_keyvault ? jsonencode({
    vaultUrl = lookup(var.key_manager_config, "vaultUrl", "")
    keyName  = lookup(var.key_manager_config, "keyName", "")
    tenantId = lookup(var.key_manager_config, "tenantId", "")
  }) : jsonencode({})

  # Credentials JSON - for Azure Key Vault includes clientId and clientSecret
  creds_json = local.is_azure_keyvault ? jsonencode({
    clientId     = lookup(var.key_manager_config, "clientId", "")
    clientSecret = lookup(var.key_manager_config, "clientSecret", "")
  }) : jsonencode({})
}

# Create key only for local key managers
# Remote signers (Azure Key Vault) use keys that already exist in the remote system
resource "kaleido_platform_kms_key" "firefly_org_key" {
  count       = local.is_local_key_manager ? 1 : 0
  name        = "firefly_org_key"
  environment = var.environment_id
  service     = kaleido_platform_service.key_manager_service[0].id
  wallet      = kaleido_platform_kms_wallet.firefly_wallet[0].id
}


# Transaction Manager

# Manages blockchain transaction lifecycle

resource "kaleido_platform_runtime" "transaction_manager_runtime" {
  count       = var.enable_transaction_manager ? 1 : 0
  type        = "TransactionManager"
  name        = var.transaction_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  config_json = jsonencode({ for k, v in var.transaction_manager_config : k => v if v != null })
}

resource "kaleido_platform_service" "transaction_manager_service" {
  count       = var.enable_transaction_manager ? 1 : 0
  type        = "TransactionManager"
  name        = var.transaction_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  runtime     = kaleido_platform_runtime.transaction_manager_runtime[0].id

  config_json = jsonencode({
    keyManager = var.enable_key_manager ? {
      id = kaleido_platform_service.key_manager_service[0].id
    } : null
    type = "evm"
    evm = {
      confirmations = {
        required = var.transaction_manager_confirmations
      }
      connector = {
        evmGateway = {
          id = var.evm_gateway_service_id
        }
      }
    }
  })

  depends_on = [
    kaleido_platform_service.key_manager_service
  ]
}


# Contract Manager

# Manages smart contract deployment

resource "kaleido_platform_runtime" "contract_manager_runtime" {
  count       = var.enable_contract_manager ? 1 : 0
  type        = "ContractManager"
  name        = var.contract_manager_name
  environment = var.environment_id
  config_json = jsonencode({ for k, v in var.contract_manager_config : k => v if v != null })
}

resource "kaleido_platform_service" "contract_manager_service" {
  count       = var.enable_contract_manager ? 1 : 0
  type        = "ContractManager"
  name        = var.contract_manager_name
  environment = var.environment_id
  runtime     = kaleido_platform_runtime.contract_manager_runtime[0].id
  config_json = jsonencode({})
}



# Hyperledger Firefly Core

# Main orchestration engine

resource "kaleido_platform_runtime" "firefly_core_runtime" {
  count       = var.enable_firefly_core ? 1 : 0
  type        = "FireFly"
  name        = var.firefly_core_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "firefly_core_service" {
  count       = var.enable_firefly_core ? 1 : 0
  type        = "FireFly"
  name        = var.firefly_core_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  runtime     = kaleido_platform_runtime.firefly_core_runtime[0].id

  config_json = jsonencode(
    var.enable_transaction_manager ? {
      transactionManager = {
        id = kaleido_platform_service.transaction_manager_service[0].id
      }
    } : {}
  )

  depends_on = [
    kaleido_platform_service.transaction_manager_service
  ]
}

