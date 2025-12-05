# ==================================================
# Kaleido Platform Credentials
# ==================================================
# REQUIRED: Update these values with your actual credentials
kaleido_platform_username = "your-email@example.com"
kaleido_platform_password = "your-kaleido-api-key-or-password"

# ==================================================
# Environment Configuration
# ==================================================
# IMPORTANT: Update this with your actual environment ID
environment_id   = "id"
environment_name = "name"

# ==================================================
# Network Configuration
# ==================================================
network_name           = "dev-blockchain-network"
network_type           = "BesuNetwork"
consensus_algorithm    = "qbft"
block_period_seconds   = 2

# ==================================================
# Node Configuration
# ==================================================
validator_node_count = 4
archive_node_count   = 1
validator_node_size  = "small"
archive_node_size    = "medium"
node_name_prefix     = "node"

# ==================================================
# Stack Configuration
# ==================================================
chain_infrastructure_stack_name = "chain-infra-stack"

# ==================================================
# Service Configuration
# ==================================================
enable_block_indexer = true
enable_evm_gateway   = true
block_indexer_name   = "block-indexer"
evm_gateway_name     = "evm-gateway"

# ==================================================
# Tags and Metadata
# ==================================================
tags = {
  Environment = "development"
  ManagedBy   = "terraform"
  Project     = "blockchain-deployment"
  Team        = "blockchain-team"
}

# ==================================================
# Advanced Configuration
# ==================================================
force_delete_nodes = false
