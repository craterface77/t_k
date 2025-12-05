# Root outputs - expose module outputs

# Environment Information
output "environment_id" {
  description = "Kaleido environment ID"
  value       = module.blockchain_chain.environment_id
}

output "environment_name" {
  description = "Environment name"
  value       = module.blockchain_chain.environment_name
}

# Network Information
output "blockchain_network_id" {
  description = "Blockchain network ID"
  value       = module.blockchain_chain.blockchain_network_id
}

output "blockchain_network_name" {
  description = "Blockchain network name"
  value       = module.blockchain_chain.blockchain_network_name
}

output "blockchain_network_type" {
  description = "Blockchain network type"
  value       = module.blockchain_chain.blockchain_network_type
}

# Stack Information
output "chain_infra_stack_id" {
  description = "Chain infrastructure stack ID"
  value       = module.blockchain_chain.chain_infra_stack_id
}

# Validator Nodes
output "validator_node_ids" {
  description = "List of validator node runtime IDs"
  value       = module.blockchain_chain.validator_node_ids
}

output "validator_node_names" {
  description = "List of validator node names"
  value       = module.blockchain_chain.validator_node_names
}

output "validator_service_ids" {
  description = "List of validator service IDs"
  value       = module.blockchain_chain.validator_service_ids
}

# Archive Nodes
output "archive_node_ids" {
  description = "List of archive node runtime IDs"
  value       = module.blockchain_chain.archive_node_ids
}

output "archive_node_names" {
  description = "List of archive node names"
  value       = module.blockchain_chain.archive_node_names
}

output "archive_service_ids" {
  description = "List of archive service IDs"
  value       = module.blockchain_chain.archive_service_ids
}

# Load Test Nodes
output "load_test_node_ids" {
  description = "List of load test node runtime IDs"
  value       = module.blockchain_chain.load_test_node_ids
}

output "load_test_node_names" {
  description = "List of load test node names"
  value       = module.blockchain_chain.load_test_node_names
}

output "load_test_service_ids" {
  description = "List of load test service IDs"
  value       = module.blockchain_chain.load_test_service_ids
}

# EVM Gateway
output "evm_gateway_runtime_id" {
  description = "EVM Gateway runtime ID"
  value       = module.blockchain_chain.evm_gateway_runtime_id
}

output "evm_gateway_service_id" {
  description = "EVM Gateway service ID"
  value       = module.blockchain_chain.evm_gateway_service_id
}

output "evm_gateway_name" {
  description = "EVM Gateway service name"
  value       = module.blockchain_chain.evm_gateway_name
}

output "evm_gateway_netinfo" {
  description = "EVM Gateway network information"
  value       = module.blockchain_chain.evm_gateway_netinfo
  sensitive   = true
}

# Block Indexer
output "block_indexer_runtime_id" {
  description = "Block Indexer runtime ID"
  value       = module.blockchain_chain.block_indexer_runtime_id
}

output "block_indexer_service_id" {
  description = "Block Indexer service ID"
  value       = module.blockchain_chain.block_indexer_service_id
}

output "block_indexer_name" {
  description = "Block Indexer service name"
  value       = module.blockchain_chain.block_indexer_name
}

# Summary
output "deployment_summary" {
  description = "Summary of deployed resources"
  value       = module.blockchain_chain.deployment_summary
}
