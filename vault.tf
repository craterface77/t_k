# HashiCorp Vault Integration
# This file manages reading all configuration from Vault

# Read all configuration from Vault
# Path structure: secret/data/kaleido/{environment}
data "vault_kv_secret_v2" "kaleido_config" {
  mount = var.vault_secret_mount
  name  = "kaleido/${var.vault_environment}"
}

# Local variables to extract all configuration
locals {
  # Extract credentials
  kaleido_credentials = {
    api_endpoint     = data.vault_kv_secret_v2.kaleido_config.data["api_endpoint"]
    username         = data.vault_kv_secret_v2.kaleido_config.data["username"]
    api_key          = data.vault_kv_secret_v2.kaleido_config.data["api_key"]
    environment_id   = data.vault_kv_secret_v2.kaleido_config.data["environment_id"]
    environment_name = data.vault_kv_secret_v2.kaleido_config.data["environment_name"]
  }

  # Extract network configuration
  network_config = {
    network_name         = data.vault_kv_secret_v2.kaleido_config.data["network_name"]
    network_type         = data.vault_kv_secret_v2.kaleido_config.data["network_type"]
    consensus_algorithm  = data.vault_kv_secret_v2.kaleido_config.data["consensus_algorithm"]
    block_period_seconds = tonumber(data.vault_kv_secret_v2.kaleido_config.data["block_period_seconds"])
  }

  # Extract node configuration
  node_config = {
    validator_node_count = tonumber(data.vault_kv_secret_v2.kaleido_config.data["validator_node_count"])
    archive_node_count   = tonumber(data.vault_kv_secret_v2.kaleido_config.data["archive_node_count"])
    validator_node_size  = data.vault_kv_secret_v2.kaleido_config.data["validator_node_size"]
    archive_node_size    = data.vault_kv_secret_v2.kaleido_config.data["archive_node_size"]
    node_name_prefix     = data.vault_kv_secret_v2.kaleido_config.data["node_name_prefix"]
  }

  # Extract stack configuration
  stack_config = {
    chain_infrastructure_stack_name = data.vault_kv_secret_v2.kaleido_config.data["chain_infrastructure_stack_name"]
  }

  # Extract service configuration
  service_config = {
    enable_block_indexer = tobool(data.vault_kv_secret_v2.kaleido_config.data["enable_block_indexer"])
    enable_evm_gateway   = tobool(data.vault_kv_secret_v2.kaleido_config.data["enable_evm_gateway"])
    block_indexer_name   = data.vault_kv_secret_v2.kaleido_config.data["block_indexer_name"]
    evm_gateway_name     = data.vault_kv_secret_v2.kaleido_config.data["evm_gateway_name"]
  }

  # Extract Firefly configuration
  firefly_config = {
    enable_firefly                    = tobool(data.vault_kv_secret_v2.kaleido_config.data["enable_firefly"])
    firefly_stack_name                = data.vault_kv_secret_v2.kaleido_config.data["firefly_stack_name"]
    enable_firefly_core               = tobool(data.vault_kv_secret_v2.kaleido_config.data["enable_firefly_core"])
    firefly_core_name                 = data.vault_kv_secret_v2.kaleido_config.data["firefly_core_name"]
    enable_transaction_manager        = tobool(data.vault_kv_secret_v2.kaleido_config.data["enable_transaction_manager"])
    transaction_manager_name          = data.vault_kv_secret_v2.kaleido_config.data["transaction_manager_name"]
    transaction_manager_confirmations = tonumber(data.vault_kv_secret_v2.kaleido_config.data["transaction_manager_confirmations"])
    enable_key_manager                = tobool(data.vault_kv_secret_v2.kaleido_config.data["enable_key_manager"])
    key_manager_name                  = data.vault_kv_secret_v2.kaleido_config.data["key_manager_name"]
    key_manager_type                  = data.vault_kv_secret_v2.kaleido_config.data["key_manager_type"]
    enable_contract_manager           = tobool(data.vault_kv_secret_v2.kaleido_config.data["enable_contract_manager"])
    contract_manager_name             = data.vault_kv_secret_v2.kaleido_config.data["contract_manager_name"]
    firefly_database_type             = data.vault_kv_secret_v2.kaleido_config.data["firefly_database_type"]
    firefly_version                   = data.vault_kv_secret_v2.kaleido_config.data["firefly_version"]
  }

  # Extract additional node configuration
  additional_node_config = {
    load_test_node_count = tonumber(data.vault_kv_secret_v2.kaleido_config.data["load_test_node_count"])
    load_test_node_size  = data.vault_kv_secret_v2.kaleido_config.data["load_test_node_size"]
    force_delete_nodes   = tobool(data.vault_kv_secret_v2.kaleido_config.data["force_delete_nodes"])
  }

  # Extract tags (stored as JSON string in Vault)
  tags = jsondecode(data.vault_kv_secret_v2.kaleido_config.data["tags"])

  # Extract complex configurations (stored as JSON strings in Vault)
  transaction_manager_config = jsondecode(data.vault_kv_secret_v2.kaleido_config.data["transaction_manager_config"])
  key_manager_config         = jsondecode(data.vault_kv_secret_v2.kaleido_config.data["key_manager_config"])
  contract_manager_config    = jsondecode(data.vault_kv_secret_v2.kaleido_config.data["contract_manager_config"])
}
