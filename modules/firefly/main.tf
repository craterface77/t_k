
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

# Create wallet and key for Firefly
resource "kaleido_platform_kms_wallet" "firefly_wallet" {
  count       = var.enable_key_manager ? 1 : 0
  type        = "hdwallet"
  name        = "firefly_wallet"
  environment = var.environment_id
  service     = kaleido_platform_service.key_manager_service[0].id
  config_json = jsonencode({})
}

resource "kaleido_platform_kms_key" "firefly_org_key" {
  count       = var.enable_key_manager ? 1 : 0
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

