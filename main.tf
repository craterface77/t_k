# Root main.tf - calls chain module and firefly module


# Blockchain Chain Module

module "blockchain_chain" {
  source = "./modules/chain"

  # Environment (from Vault)
  environment_id   = local.kaleido_credentials.environment_id
  environment_name = local.kaleido_credentials.environment_name

  # Network (from Vault)
  network_name                    = local.network_config.network_name
  network_type                    = local.network_config.network_type
  consensus_algorithm             = local.network_config.consensus_algorithm
  block_period_seconds            = local.network_config.block_period_seconds
  chain_infrastructure_stack_name = local.stack_config.chain_infrastructure_stack_name

  # Nodes (from Vault)
  validator_node_count = local.node_config.validator_node_count
  archive_node_count   = local.node_config.archive_node_count
  load_test_node_count = local.additional_node_config.load_test_node_count
  validator_node_size  = local.node_config.validator_node_size
  archive_node_size    = local.node_config.archive_node_size
  load_test_node_size  = local.additional_node_config.load_test_node_size
  node_name_prefix     = local.node_config.node_name_prefix
  force_delete_nodes   = local.additional_node_config.force_delete_nodes

  # Services (from Vault)
  enable_block_indexer = local.service_config.enable_block_indexer
  enable_evm_gateway   = local.service_config.enable_evm_gateway
  block_indexer_name   = local.service_config.block_indexer_name
  evm_gateway_name     = local.service_config.evm_gateway_name

  # Tags (from Vault)
  tags = local.tags
}


# Hyperledger Firefly Module

module "firefly_middleware" {
  source = "./modules/firefly"

  # Only deploy if Firefly is enabled
  # NOTE: count must be known at plan time, so we use a variable instead of Vault
  count = var.enable_firefly ? 1 : 0

  # Environment (from Vault)
  environment_id   = local.kaleido_credentials.environment_id
  environment_name = local.kaleido_credentials.environment_name

  # Connect to existing blockchain network
  network_id             = module.blockchain_chain.blockchain_network_id
  evm_gateway_service_id = module.blockchain_chain.evm_gateway_service_id

  # Stack Configuration (from Vault)
  firefly_stack_name = local.firefly_config.firefly_stack_name

  # Firefly Core (from Vault)
  enable_firefly_core = local.firefly_config.enable_firefly_core
  firefly_core_name   = local.firefly_config.firefly_core_name

  # Transaction Manager (from Vault)
  enable_transaction_manager        = local.firefly_config.enable_transaction_manager
  transaction_manager_name          = local.firefly_config.transaction_manager_name
  transaction_manager_confirmations = local.firefly_config.transaction_manager_confirmations
  transaction_manager_config        = local.transaction_manager_config

  # Key Manager (from Vault)
  enable_key_manager = local.firefly_config.enable_key_manager
  key_manager_name   = local.firefly_config.key_manager_name
  key_manager_type   = local.firefly_config.key_manager_type
  key_manager_config = local.key_manager_config

  # Contract Manager (from Vault)
  enable_contract_manager = local.firefly_config.enable_contract_manager
  contract_manager_name   = local.firefly_config.contract_manager_name
  contract_manager_config = local.contract_manager_config

  # Database Configuration (from Vault)
  database_type = local.firefly_config.firefly_database_type

  # Advanced Configuration (from Vault)
  firefly_version = local.firefly_config.firefly_version

  # Tags (from Vault)
  tags = merge(local.tags, {
    Component = "firefly-middleware"
  })

  depends_on = [
    module.blockchain_chain
  ]
}
