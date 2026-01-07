# Storing ALL Configuration in Vault

## Overview

This project now stores **ALL configuration variables** in HashiCorp Vault, not just credentials. This provides:

- ✅ **Centralized Configuration Management** - Single source of truth for all environments
- ✅ **Environment Isolation** - Complete separation between dev/sit/prod configurations
- ✅ **Audit Trail** - Track all configuration changes
- ✅ **Access Control** - Granular permissions for configuration access
- ✅ **Easy Environment Switching** - Change environments by switching Vault paths
- ✅ **No Local Files** - No need for `.tfvars` files with sensitive or environment-specific data

---

## What's Stored in Vault

### 1. Credentials (Sensitive)

```
api_endpoint      = "https://account1.platform.ape1-c1.scb.kaleido.cloud"
username          = "test-oleh2"
api_key           = "ba95c7c2-43b4-4690-8689-11f3410027a16346625c-13e6-4be3-b1a9-f069c218d31e"
environment_id    = "e:fryskwx4xf"
```

### 2. Network Configuration

```
network_name         = "sc-chain-casa-dev-network"
network_type         = "BesuNetwork"
consensus_algorithm  = "qbft"
block_period_seconds = "4"
```

### 3. Node Configuration

```
validator_node_count = "4"
archive_node_count   = "1"
validator_node_size  = "small"
archive_node_size    = "medium"
node_name_prefix     = "node"
```

### 4. Stack Configuration

```
chain_infrastructure_stack_name = "sc-chain-casa-dev-chain"
```

### 5. Service Configuration

```
enable_block_indexer = "true"
enable_evm_gateway   = "true"
block_indexer_name   = "block-indexer"
evm_gateway_name     = "evm-gateway"
```

### 6. Firefly Middleware Configuration

```
enable_firefly              = "true"
firefly_stack_name          = "sc-chain-casa-dev-middleware"
enable_firefly_core         = "true"
firefly_core_name           = "sc-chain-casa-core"
enable_transaction_manager  = "true"
transaction_manager_name    = "sc-chain-casa-dev-txmanager"
enable_key_manager          = "true"
key_manager_name            = "sc-chain-casa-dev-signer"
key_manager_type            = "HDWalletSigner"
enable_contract_manager     = "true"
contract_manager_name       = "sc-chain-casa-dev-contracts"
firefly_database_type       = "postgres"
```

### 7. Complex Configurations (JSON)

```
transaction_manager_config = '{"maxInFlight":100,"gasOracleMode":"connector","txTimeout":300,"autoRetry":true}'
key_manager_config         = '{"keystorePath":"/data/keystore","signingAlgorithm":"secp256k1","hsmEnabled":false}'
contract_manager_config    = '{"autoConfirm":true,"confirmations":1,"defaultGasLimit":5000000,"verifyBytecode":true}'
```

---

## Quick Start

### 1. Store Configuration in Vault

**Option 1: Use Script (Recommended)**

```bash
# Make script executable (first time only)
chmod +x vault-store-config.sh

# Store dev configuration
./vault-store-config.sh dev
```

**Option 2: Manual Command**

```bash
vault kv put secret/kaleido/dev \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="test-oleh2" \
  api_key="ba95c7c2-43b4-4690-8689-11f3410027a16346625c-13e6-4be3-b1a9-f069c218d31e" \
  environment_id="e:fryskwx4xf" \
  network_name="sc-chain-casa-dev-network" \
  network_type="BesuNetwork" \
  consensus_algorithm="qbft" \
  block_period_seconds="4" \
  validator_node_count="4" \
  archive_node_count="1" \
  validator_node_size="small" \
  archive_node_size="medium" \
  node_name_prefix="node" \
  chain_infrastructure_stack_name="sc-chain-casa-dev-chain" \
  enable_block_indexer="true" \
  enable_evm_gateway="true" \
  block_indexer_name="block-indexer" \
  evm_gateway_name="evm-gateway" \
  enable_firefly="true" \
  firefly_stack_name="sc-chain-casa-dev-middleware" \
  enable_firefly_core="true" \
  firefly_core_name="sc-chain-casa-core" \
  enable_transaction_manager="true" \
  transaction_manager_name="sc-chain-casa-dev-txmanager" \
  enable_key_manager="true" \
  key_manager_name="sc-chain-casa-dev-signer" \
  key_manager_type="HDWalletSigner" \
  enable_contract_manager="true" \
  contract_manager_name="sc-chain-casa-dev-contracts" \
  firefly_database_type="postgres" \
  transaction_manager_config='{"maxInFlight":100,"gasOracleMode":"connector","txTimeout":300,"autoRetry":true}' \
  key_manager_config='{"keystorePath":"/data/keystore","signingAlgorithm":"secp256k1","hsmEnabled":false}' \
  contract_manager_config='{"autoConfirm":true,"confirmations":1,"defaultGasLimit":5000000,"verifyBytecode":true}'
```

### 2. Verify Configuration

```bash
# View all stored configuration
vault kv get secret/kaleido/dev

# View specific field
vault kv get -field=network_name secret/kaleido/dev

# View all environments
vault kv list secret/kaleido
```

### 3. Deploy with Terraform

```bash
# Ensure Vault environment variables are set
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='your-vault-token'

# Deploy to dev
make plan ENV=dev
make apply ENV=dev
```

---

## How It Works

### Architecture

```
┌──────────────────────┐
│   Terraform          │
│                      │
│  1. Reads ALL config │
│     from Vault       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│   Vault Server       │
│                      │
│  secret/kaleido/dev  │──┐
│  secret/kaleido/sit  │  │ ALL configuration
│  secret/kaleido/prod │  │ for each environment
│                      │  │
│  - Credentials       │◄─┘
│  - Network config    │
│  - Node config       │
│  - Service config    │
│  - Firefly config    │
└──────────────────────┘
```

### File Structure

```
vault.tf              # Reads ALL config from Vault
├── kaleido_credentials
├── network_config
├── node_config
├── stack_config
├── service_config
└── firefly_config

main.tf               # Uses Vault locals instead of variables
├── module "blockchain_chain"
│   └── Uses local.network_config, local.node_config, etc.
└── module "firefly_middleware"
    └── Uses local.firefly_config, local.transaction_manager_config, etc.

vars/dev.tfvars       # Now mostly empty (optional overrides only)
```

---

## Managing Configuration

### Update a Single Value

```bash
# Update network name
vault kv patch secret/kaleido/dev network_name="new-network-name"

# Update node count
vault kv patch secret/kaleido/dev validator_node_count="6"

# Update complex config (JSON)
vault kv patch secret/kaleido/dev \
  transaction_manager_config='{"maxInFlight":200,"gasOracleMode":"connector","txTimeout":600,"autoRetry":true}'
```

### Update All Configuration

```bash
# Re-run the script with updated values
./vault-store-config.sh dev

# Or use vault kv put with all values (replaces everything)
```

### Copy Configuration Between Environments

```bash
# Get dev configuration
vault kv get -format=json secret/kaleido/dev > dev-config.json

# Modify for SIT environment
# (edit dev-config.json, change environment-specific values)

# Store as SIT configuration
vault kv put secret/kaleido/sit @sit-config.json
```

### Delete Configuration

```bash
# Soft delete (can be recovered)
vault kv delete secret/kaleido/dev

# Permanent delete
vault kv destroy secret/kaleido/dev
```

---

## Multiple Environments

### Development

```bash
# Store dev configuration
./vault-store-config.sh dev

# Deploy
make apply ENV=dev
```

### SIT

```bash
# Store SIT configuration (modify script or use manual command)
vault kv put secret/kaleido/sit \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="sit-user" \
  api_key="sit-api-key" \
  environment_id="e:sit123" \
  network_name="sc-chain-casa-sit-network" \
  # ... all other SIT-specific values

# Deploy
make apply ENV=sit
```

### Production

```bash
# Store production configuration
vault kv put secret/kaleido/prod \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="prod-user" \
  api_key="prod-api-key" \
  environment_id="e:prod456" \
  network_name="sc-chain-casa-prod-network" \
  # ... all other production-specific values

# Deploy
make apply ENV=prod
```

---

## Benefits

### 1. Centralized Configuration

**Before (with .tfvars):**

- Configuration scattered across multiple files
- Hard to track changes
- Easy to commit sensitive data

**After (with Vault):**

- Single source of truth per environment
- Complete audit trail
- Impossible to commit sensitive data

### 2. Environment Switching

**Before:**

```bash
terraform apply -var-file=vars/dev.tfvars
# Oops, used wrong file!
```

**After:**

```bash
make apply ENV=dev
# Makefile ensures correct environment, Vault validates connection
```

### 3. Configuration Versioning

```bash
# View configuration history
vault kv metadata get secret/kaleido/dev

# Rollback to previous version
vault kv rollback -version=2 secret/kaleido/dev
```

### 4. Access Control

```hcl
# Allow read-only access to dev configuration
path "secret/data/kaleido/dev" {
  capabilities = ["read"]
}

# Allow full access to sit configuration
path "secret/data/kaleido/sit" {
  capabilities = ["read", "update"]
}

# Deny access to prod configuration
path "secret/data/kaleido/prod" {
  capabilities = ["deny"]
}
```

---

## What Variables Stay in .tfvars?

Some variables still remain in `.tfvars` for flexibility:

```hcl
# vars/dev.tfvars (optional overrides)

# Variables that change frequently during development
environment_name = "dlt-da-01"  # Used for Vault path lookup

# Variables not in Vault yet
load_test_node_count = 0
load_test_node_size  = "small"

# Safety flags
force_delete_nodes = false

# Non-sensitive metadata
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "sc-chain-casa"
}

# Version pinning
firefly_version = "latest"
transaction_manager_confirmations = 3
```

**Note:** Even these can be moved to Vault if needed! The choice is yours.

---

## Troubleshooting

### Configuration Not Found

```bash
# Check if configuration exists
vault kv get secret/kaleido/dev

# If not, create it
./vault-store-config.sh dev
```

### Wrong Configuration Loaded

```bash
# Verify environment name matches
echo $ENV  # Should match Vault path

# Check what Terraform will use
terraform console
> local.network_config
```

### Complex Config Parsing Errors

```bash
# Complex configs must be valid JSON strings
# Good:
transaction_manager_config='{"maxInFlight":100,"autoRetry":true}'

# Bad (will fail):
transaction_manager_config='{maxInFlight:100,autoRetry:true}'  # Not valid JSON
```

---

## Security Best Practices

1. **Use Vault ACL Policies** - Limit who can read/write configuration
2. **Enable Audit Logging** - Track all configuration changes
3. **Rotate Credentials Regularly** - Update API keys in Vault
4. **Use Different Vault Tokens** - Per environment or per user
5. **Backup Vault Data** - Regular snapshots of configuration
6. **Use Production Vault** - Not dev server for real deployments

---

## Next Steps

1. ✅ Store dev configuration in Vault
2. ✅ Test deployment: `make apply ENV=dev`
3. ⏭️ Create SIT configuration
4. ⏭️ Create production configuration
5. ⏭️ Setup Vault ACL policies
6. ⏭️ Configure CI/CD with Vault
7. ⏭️ Setup production Vault server

---

## Additional Resources

- [VAULT_SETUP_GUIDE.md](VAULT_SETUP_GUIDE.md) - Initial setup guide
- [QUICK_START.md](QUICK_START.md) - 5-minute quick start
- [docs/VAULT_INTEGRATION.md](docs/VAULT_INTEGRATION.md) - Complete documentation
- [Vault Documentation](https://www.vaultproject.io/docs)
- [Vault KV v2 Engine](https://www.vaultproject.io/docs/secrets/kv/kv-v2)

---

## Support

For issues or questions:

1. Check [Troubleshooting](#troubleshooting) section
2. Verify Vault connection: `make vault-check ENV=dev`
3. Review Vault logs: `vault status`
4. Check Terraform console: `terraform console`
