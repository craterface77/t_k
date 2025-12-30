# Kaleido Platform Credentials
kaleido_platform_api = "kaleido_platform_api"
kaleido_platform_username = "your-email@example.com"
kaleido_platform_api_key = "your-kaleido-api-key-or-password"

# Environment Configuration
# IMPORTANT: Update this with your actual environment ID
environment_id   = "id"
environment_name = "name"

# Network Configuration
network_name         = "sc-chain-casa-dev-network"
network_type         = "BesuNetwork"
consensus_algorithm  = "qbft"
block_period_seconds = 4

# Node Configuration
validator_node_count = 4
archive_node_count   = 1
validator_node_size  = "small"
archive_node_size    = "medium"
node_name_prefix     = "node"

# Stack Configuration
chain_infrastructure_stack_name = "sc-chain-casa-dev-chain"

# Service Configuration
enable_block_indexer = true
enable_evm_gateway   = true
block_indexer_name   = "block-indexer"
evm_gateway_name     = "evm-gateway"

# Hyperledger Firefly Configuration
# Single party mode - for ONE blockchain only
enable_firefly = true

# Stack Configuration
firefly_stack_name = "sc-chain-casa-dev-middleware"

# Firefly Core
enable_firefly_core = true
firefly_core_name   = "sc-chain-casa-core"

# Transaction Manager
enable_transaction_manager = true
transaction_manager_name   = "sc-chain-casa-dev-txmanager"

# Custom transaction manager configuration (optional)
transaction_manager_config = {
  maxInFlight = 100
  gasOracleMode = "connector"
  txTimeout = 300
  autoRetry = true
}

# Key Manager (Signer)
enable_key_manager = true
key_manager_name   = "sc-chain-casa-dev-signer"
key_manager_type   = "HDWalletSigner" # Options: FireFlySigner, HDWalletSigner

# Custom key manager configuration (optional)
key_manager_config = {
  keystorePath = "/data/keystore"
  signingAlgorithm = "secp256k1"
  hsmEnabled = false
}

# Contract Manager
enable_contract_manager = true
contract_manager_name   = "sc-chain-casa-dev-contracts"

# Custom contract manager configuration (optional)
contract_manager_config = {
  autoConfirm = true
  confirmations = 1
  defaultGasLimit = 5000000
  verifyBytecode = true
}

# Database Configuration
firefly_database_type = "postgres" # Options: postgres, sqlite
