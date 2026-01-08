# Azure Key Vault Remote Signing Module (conditional)
# Only created if key_manager_type = "AzureKeyVaultSigner" in Vault
module "azure_remote_signing" {
  source = "./modules/remote-signing/azure-keyvault"

  # Only create if using Azure Key Vault signing
  count = local.firefly_config.key_manager_type == "AzureKeyVaultSigner" ? 1 : 0

  # Key Vault infrastructure
  create_key_vault    = local.azure_config.create_key_vault
  key_vault_name      = local.azure_config.key_vault_name
  resource_group_name = local.azure_config.resource_group_name

  # Azure AD Configuration
  tenant_id                           = local.azure_config.tenant_id
  kaleido_service_principal_object_id = local.azure_config.sp_object_id
  kaleido_service_principal_client_id = local.azure_config.client_id

  # Signing Key Configuration
  create_signing_key = local.azure_config.create_signing_key
  signing_key_name   = local.azure_config.signing_key_name
  key_type           = local.azure_config.key_type
  key_size           = local.azure_config.key_size

  # Security
  network_default_action = local.azure_config.network_default_action
  allowed_ip_ranges      = local.kaleido_ip_ranges

  tags = local.tags
}


# Blockchain Chain Module

module "blockchain_chain" {
  source = "./modules/chain"

  # Environment
  environment_id   = local.kaleido_credentials.environment_id
  environment_name = local.kaleido_credentials.environment_name

  # Network
  network_name                    = local.network_config.network_name
  network_type                    = local.network_config.network_type
  consensus_algorithm             = local.network_config.consensus_algorithm
  block_period_seconds            = local.network_config.block_period_seconds
  chain_infrastructure_stack_name = local.stack_config.chain_infrastructure_stack_name

  # Nodes
  validator_node_count = local.node_config.validator_node_count
  archive_node_count   = local.node_config.archive_node_count
  load_test_node_count = local.additional_node_config.load_test_node_count
  validator_node_size  = local.node_config.validator_node_size
  archive_node_size    = local.node_config.archive_node_size
  load_test_node_size  = local.additional_node_config.load_test_node_size
  node_name_prefix     = local.node_config.node_name_prefix
  force_delete_nodes   = local.additional_node_config.force_delete_nodes

  # Services
  enable_block_indexer = local.service_config.enable_block_indexer
  enable_evm_gateway   = local.service_config.enable_evm_gateway
  block_indexer_name   = local.service_config.block_indexer_name
  evm_gateway_name     = local.service_config.evm_gateway_name

  # Tags
  tags = local.tags
}


# Hyperledger Firefly Module

module "firefly_middleware" {
  source = "./modules/firefly"

  # Only deploy if Firefly is enabled
  # NOTE: count must be known at plan time, so we use a variable instead of Vault
  count = var.enable_firefly ? 1 : 0

  # Environment
  environment_id   = local.kaleido_credentials.environment_id
  environment_name = local.kaleido_credentials.environment_name

  # Connect to existing blockchain network
  network_id             = module.blockchain_chain.blockchain_network_id
  evm_gateway_service_id = module.blockchain_chain.evm_gateway_service_id

  # Stack Configuration
  firefly_stack_name = local.firefly_config.firefly_stack_name

  # Firefly Core
  enable_firefly_core = local.firefly_config.enable_firefly_core
  firefly_core_name   = local.firefly_config.firefly_core_name

  # Transaction Manager
  enable_transaction_manager        = local.firefly_config.enable_transaction_manager
  transaction_manager_name          = local.firefly_config.transaction_manager_name
  transaction_manager_confirmations = local.firefly_config.transaction_manager_confirmations
  transaction_manager_config        = local.transaction_manager_config

  # Key Manager
  enable_key_manager = local.firefly_config.enable_key_manager
  key_manager_name   = local.firefly_config.key_manager_name
  key_manager_type   = local.firefly_config.key_manager_type

  # Key Manager Config - conditional based on type
  # For Azure Key Vault: merge Azure config with module outputs
  # For HDWallet: use config from Vault as-is
  key_manager_config = local.firefly_config.key_manager_type == "AzureKeyVaultSigner" ? merge(
    local.key_manager_config,
    {
      vaultUrl     = module.azure_remote_signing[0].key_vault_uri
      keyName      = module.azure_remote_signing[0].signing_key_name
      tenantId     = local.azure_config.tenant_id
      clientId     = local.azure_config.client_id
      clientSecret = local.azure_config.client_secret
    }
  ) : local.key_manager_config

  # Contract Manager
  enable_contract_manager = local.firefly_config.enable_contract_manager
  contract_manager_name   = local.firefly_config.contract_manager_name
  contract_manager_config = local.contract_manager_config

  # Database Configuration
  database_type = local.firefly_config.firefly_database_type

  # Advanced Configuration
  firefly_version = local.firefly_config.firefly_version

  # Tags
  tags = merge(local.tags, {
    Component = "firefly-middleware"
  })

  depends_on = [
    module.blockchain_chain,
    module.azure_remote_signing # Only exists if Azure Key Vault enabled
  ]
}


# Outputs (conditional - only for Azure Key Vault)
output "azure_key_vault_uri" {
  description = "Azure Key Vault URI for Firefly configuration (only if using AzureKeyVaultSigner)"
  value       = length(module.azure_remote_signing) > 0 ? module.azure_remote_signing[0].key_vault_uri : null
}

output "signing_key_name" {
  description = "Name of the signing key (only if using AzureKeyVaultSigner)"
  value       = length(module.azure_remote_signing) > 0 ? module.azure_remote_signing[0].signing_key_name : null
}
