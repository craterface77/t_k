# Root main.tf - calls chain module

module "blockchain_chain" {
  source = "./modules/chain"

  # Environment
  environment_id   = var.environment_id
  environment_name = var.environment_name

  # Network
  network_name                    = var.network_name
  network_type                    = var.network_type
  consensus_algorithm             = var.consensus_algorithm
  block_period_seconds            = var.block_period_seconds
  chain_infrastructure_stack_name = var.chain_infrastructure_stack_name

  # Nodes
  validator_node_count = var.validator_node_count
  archive_node_count   = var.archive_node_count
  validator_node_size  = var.validator_node_size
  archive_node_size    = var.archive_node_size
  node_name_prefix     = var.node_name_prefix
  force_delete_nodes   = var.force_delete_nodes

  # Services
  enable_block_indexer = var.enable_block_indexer
  enable_evm_gateway   = var.enable_evm_gateway
  block_indexer_name   = var.block_indexer_name
  evm_gateway_name     = var.evm_gateway_name

  # Tags
  tags = var.tags
}
