# Kaleido Blockchain Terraform Provider

Production-ready Terraform configuration for deploying Hyperledger Besu blockchain networks with Hyperledger Firefly middleware on Kaleido platform.

## 🚀 Key Features

- **Unified Configuration**: Single codebase supporting both HDWallet (local) and Azure Key Vault (HSM-backed remote signing)
- **HashiCorp Vault Integration**: All 49 configuration parameters stored securely in Vault
- **Automatic Mode Detection**: Switches between HDWallet and Azure Key Vault based on `key_manager_type` parameter
- **Production Ready**: No hardcoded credentials, follows security best practices
- **Modular Architecture**: Clean separation of blockchain chain and Firefly middleware components

## 📋 Architecture Overview

This repository deploys:

- **Blockchain Network** (Hyperledger Besu)
  - Validator nodes
  - Archive nodes
  - EVM Gateway
  - Block Indexer
- **Hyperledger Firefly Middleware**
  - Firefly Core
  - Transaction Manager
  - Key Manager (HDWallet OR Azure Key Vault)
  - Contract Manager
- **Azure Key Vault Integration** (Optional, Production)
  - HSM-backed signing keys
  - FIPS 140-2 Level 3 compliance
  - Keys never leave Azure Key Vault

## 🔐 HashiCorp Vault Integration

All 49 configuration parameters are stored securely in HashiCorp Vault.

### Configuration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    HashiCorp Vault                          │
│              (49 configuration parameters)                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   Terraform (main.tf)                        │
│                                                              │
│  Conditional: key_manager_type == "AzureKeyVaultSigner"     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Azure Key Vault Module (count = 0 or 1)            │   │
│  │  - Create/Use Key Vault                              │   │
│  │  - Create/Use HSM Signing Key                        │   │
│  │  - Configure Network Security                        │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Blockchain Chain Module                             │   │
│  │  - Validator/Archive Nodes                           │   │
│  │  - Block Indexer + EVM Gateway                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Firefly Middleware Module                           │   │
│  │  - Key Manager (HDWallet OR Azure Key Vault)        │   │
│  │  - Transaction Manager + Contract Manager            │   │
│  │  - Firefly Core                                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### What's in Vault vs tfvars

**In tfvars (Only 2 parameters):**
- `vault_environment` - Which Vault path to read (dev/prod)
- `enable_firefly` - Must be known at plan time for Terraform count

**In Vault (49 parameters):**
- **Common (35 parameters):** Kaleido credentials, network config, node config, Firefly services, tags
- **Azure-specific (14 parameters):** Azure AD, Key Vault infrastructure, signing key config, network security

## 🚦 Quick Start

### 1. Start HashiCorp Vault

#### Development
```bash
vault server -dev -dev-root-token-id=root &
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'
```

#### Production
See [PRODUCTION_SETUP_GUIDE.md](PRODUCTION_SETUP_GUIDE.md)

### 2. Store Configuration in Vault

#### For Development (HDWallet)
```bash
# Edit with your Kaleido credentials
vim vault-store-config-hdwallet.sh

# Run script
./vault-store-config-hdwallet.sh dev
```

#### For Production (Azure Key Vault)
```bash
# Edit with your Azure and Kaleido credentials
vim vault-store-config-azure-keyvault.sh

# Set Azure client secret
export AZURE_CLIENT_SECRET='your-service-principal-password'

# Run script
./vault-store-config-azure-keyvault.sh prod
```

### 3. Configure Azure Provider (Production Only)

```bash
export ARM_SUBSCRIPTION_ID="your-azure-subscription-id"
export ARM_TENANT_ID="your-azure-tenant-id"
export ARM_CLIENT_ID="your-service-principal-client-id"
export ARM_CLIENT_SECRET="your-service-principal-password"
```

### 4. Deploy

```bash
# Development
make plan ENV=dev
make apply ENV=dev

# Production
make plan ENV=prod
make apply ENV=prod
```

---

## Using Makefile (Recommended)

The Makefile provides automated Vault integration and simplified commands.

### Automatic Vault Configuration

The Makefile **automatically exports** `VAULT_ADDR` and `VAULT_TOKEN`:

```makefile
export VAULT_ADDR ?= http://127.0.0.1:8200
export VAULT_TOKEN ?= root
```

You can override these with environment variables if needed.

### Available Commands

```bash
# Get help and see all commands
make help

# Vault operations
make vault-check ENV=dev         # Verify Vault connection and credentials

# Terraform operations
make init ENV=dev                # Initialize Terraform
make plan ENV=dev                # Show execution plan
make apply ENV=dev               # Apply changes
make apply-auto ENV=dev          # Apply without confirmation
make destroy ENV=dev             # Destroy resources
make output                      # Show outputs

# Development shortcuts
make dev-plan                    # Quick: make plan ENV=dev
make dev-apply                   # Quick: make apply ENV=dev

# Other environments
make sit-plan                    # Plan for SIT environment
make prod-apply                  # Apply to production

# Utilities
make validate                    # Validate configuration
make fmt                         # Format Terraform files
make state-list                  # List all resources
make clean                       # Clean Terraform files
```

### Workflow Example

```bash
# 1. Check Vault connection
make vault-check ENV=dev

# 2. Initialize (first time only)
make init ENV=dev

# 3. Plan changes
make plan ENV=dev

# 4. Apply changes
make apply ENV=dev

# 5. View outputs
make output
```

### Multi-Environment Support

```bash
# Development
make plan ENV=dev
make apply ENV=dev

# SIT (System Integration Testing)
make plan ENV=sit
make apply ENV=sit

# Production
make plan ENV=prod
make apply ENV=prod
```

Each environment has its own:

- Vault path: `secret/kaleido/{environment}`
- Tfvars file: `vars/{environment}.tfvars`
- Separate credentials and configuration

---

## Quick Start - Unified Deployment (Blockchain + Firefly)

All configuration is now stored in Vault. The `vars/dev.tfvars` file only contains 2 variables.

### 1. Start Vault

```bash
# Start Vault in dev mode
vault server -dev

# Note the Root Token from the output
```

### 2. Store Configuration in Vault

```bash
# In another terminal, export Vault credentials
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='hvs.xxxxxxxxxxxxx'  # Use Root Token from step 1

# Store ALL configuration (40+ parameters) in Vault
./vault-store-config.sh dev

# Verify configuration was stored
vault kv get secret/kaleido/dev
```

### 3. Review Minimal Configuration File

```bash
cat vars/dev.tfvars
```

The file now contains only 2 variables:

```hcl
vault_environment = "dev"  # Which Vault path to read
enable_firefly = true      # Must be known at plan time
```

**All other configuration** (credentials, network settings, node counts, Firefly services, etc.) is loaded from Vault.

### 4. Deploy Infrastructure

```bash
# Makefile automatically uses Vault credentials
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
```

**Note:** No need to manually export VAULT_ADDR/VAULT_TOKEN - Makefile does it automatically!

### 5. View Outputs

```bash
make output
```

## Customizing Configuration

### Disable Firefly (Deploy Blockchain Only)

Edit `vars/dev.tfvars`:

```hcl
vault_environment = "dev"
enable_firefly = false  # Change to false
```

Then apply:

```bash
make apply ENV=dev
```

### Enable/Disable Individual Services

Individual service settings are stored in Vault. To modify:

```bash
# Update configuration in Vault
vault kv patch secret/kaleido/dev \
  enable_firefly_core=false \
  enable_contract_manager=false

# Apply changes
make apply ENV=dev
```

Or update via the script:

```bash
# Edit vault-store-config.sh with your desired settings
# Then re-run:
./vault-store-config.sh dev
make apply ENV=dev
```

## Configuration Storage Overview

### Variables in dev.tfvars (2 variables)

| Parameter           | Location   | Notes                                     |
| ------------------- | ---------- | ----------------------------------------- |
| `vault_environment` | dev.tfvars | Which Vault path to read (dev/sit/prod)   |
| `enable_firefly`    | dev.tfvars | Must be in tfvars (count must be at plan) |

### All Other Configuration in Vault (40+ parameters)

**Credentials:**

- `api_endpoint`, `username`, `api_key`, `environment_id`, `environment_name`

**Network Configuration:**

- `network_name`, `network_type`, `consensus_algorithm`, `block_period_seconds`

**Node Configuration:**

- `validator_node_count`, `archive_node_count`, `load_test_node_count`
- `validator_node_size`, `archive_node_size`, `load_test_node_size`
- `node_name_prefix`, `force_delete_nodes`

**Stack Configuration:**

- `chain_infrastructure_stack_name`

**Service Configuration:**

- `enable_block_indexer`, `enable_evm_gateway`
- `block_indexer_name`, `evm_gateway_name`

**Firefly Configuration:**

- `firefly_stack_name`, `firefly_version`
- `enable_firefly_core`, `firefly_core_name`
- `enable_transaction_manager`, `transaction_manager_name`, `transaction_manager_confirmations`
- `enable_key_manager`, `key_manager_name`, `key_manager_type`
- `enable_contract_manager`, `contract_manager_name`
- `firefly_database_type`

**Complex Configurations (JSON):**

- `transaction_manager_config`
- `key_manager_config`
- `contract_manager_config`
- `tags`

### Modifying Configuration

To change any Vault-stored parameter:

```bash
# Option 1: Patch specific values
vault kv patch secret/kaleido/dev \
  validator_node_count=6 \
  archive_node_count=2

# Option 2: Edit script and re-run
vim vault-store-config.sh
./vault-store-config.sh dev

# Apply changes
make apply ENV=dev
```

## Component Management Guide

Complete guide for adding and removing blockchain network and middleware components.

### Adding Components

#### Adding Validator Nodes

Validator nodes participate in consensus and validate transactions.

**Steps:**

1. **Edit Configuration**

   Open `vars/dev.tfvars` and increase the validator count:

   ```hcl
   # vars/dev.tfvars
   validator_node_count = 6  # Increased from 4
   ```

2. **Review Changes**

   ```bash
   terraform plan -var-file="vars/dev.tfvars"
   ```

3. **Apply Changes**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

---

#### Adding Archive Nodes

Archive nodes store full blockchain history.

**Steps:**

1. **Edit Configuration**

   ```hcl
   # vars/dev.tfvars
   archive_node_count = 2  # Increased from 1
   ```

2. **Review and Apply**

   ```bash
   terraform plan -var-file="vars/dev.tfvars"
   terraform apply -var-file="vars/dev.tfvars"
   ```

**Result:**

- Creates `node-archive-2`
- Existing archive node unchanged
- New node syncs full history

---

#### Adding Block Indexer

Block Indexer provides indexed blockchain data access.

**Prerequisites:**

- EVM Gateway must be enabled

**Steps:**

1. **Edit Configuration**

   ```hcl
   # vars/dev.tfvars
   enable_block_indexer = true
   block_indexer_name   = "block-indexer"
   ```

2. **Apply Changes**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

**Result:**

- Creates Block Indexer runtime and service
- Connects to EVM Gateway
- Starts indexing from genesis

---

#### Adding EVM Gateway

EVM Gateway provides JSON-RPC interface to the blockchain.

**Steps:**

1. **Edit Configuration**

   ```hcl
   # vars/dev.tfvars
   enable_evm_gateway = true
   evm_gateway_name   = "evm-gateway"
   ```

2. **Apply Changes**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

**Result:**

- Creates EVM Gateway runtime and service
- Provides JSON-RPC endpoints
- Required for Firefly integration

---

#### Adding Firefly Middleware

Add complete Firefly middleware stack to existing blockchain.

**Prerequisites:**

- Blockchain network must be deployed
- EVM Gateway must be enabled

**Steps:**

1. **Edit Configuration**

   ```hcl
   # vars/dev.tfvars
   enable_firefly = true

   # Stack name
   firefly_stack_name = "firefly-middleware-stack"

   # Core services
   enable_firefly_core        = true
   firefly_core_name          = "firefly-core"

   enable_transaction_manager = true
   transaction_manager_name   = "firefly-txmanager"

   enable_key_manager         = true
   key_manager_name           = "firefly-signer"
   key_manager_type           = "HDWalletSigner"

   enable_contract_manager    = true
   contract_manager_name      = "firefly-contracts"

   # Database
   firefly_database_type = "postgres"
   ```

2. **Review Changes**

   ```bash
   terraform plan -var-file="vars/dev.tfvars"
   ```

   Expected: ~20-25 resources to add

3. **Apply Changes**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

**Result:**

- Creates Firefly middleware stack
- Deploys all enabled services
- Connects to existing blockchain via EVM Gateway
- Creates wallet and keys

**Deployment Time:** ~5-10 minutes

---

#### Adding Individual Firefly Services

Add specific services to existing Firefly stack.

##### Adding Transaction Manager

```hcl
# vars/dev.tfvars
enable_transaction_manager = true
transaction_manager_name   = "firefly-txmanager"

# Optional: Custom configuration
transaction_manager_config = {
  maxInFlight   = 100
  gasOracleMode = "connector"
  txTimeout     = 300
  autoRetry     = true
}
```

##### Adding Contract Manager

```hcl
# vars/dev.tfvars
enable_contract_manager = true
contract_manager_name   = "firefly-contracts"

# Optional: Custom configuration
contract_manager_config = {
  autoConfirm     = true
  confirmations   = 12
  defaultGasLimit = 5000000
  verifyBytecode  = true
}
```

##### Adding Key Manager

```hcl
# vars/dev.tfvars
enable_key_manager = true
key_manager_name   = "firefly-signer"
key_manager_type   = "HDWalletSigner"  # or "FireFlySigner"

# Optional: Custom configuration
key_manager_config = {
  keystorePath     = "/data/keystore"
  signingAlgorithm = "secp256k1"
  hsmEnabled       = false
}
```

**Apply:**

```bash
terraform apply -var-file="vars/dev.tfvars"
```

---

### Deleting Components

#### Important Warnings

- **Data Loss:** Deleting components results in permanent data loss
- **Dependencies:** Check dependencies before deletion
- **Backups:** Always backup critical data before deletion
- **Validator Quorum:** Maintain minimum validators for consensus

---

#### Removing Nodes

##### Removing Validator Nodes

**CRITICAL:** Ensure you maintain consensus quorum!

For QBFT consensus:

- Minimum: 4 validators
- Formula: 3f + 1 (where f = Byzantine fault tolerance)

**Steps:**

1. **Check Current Count**

   ```bash
   terraform output validator_node_names
   # Output: ["node-validator-1", "node-validator-2", "node-validator-3", "node-validator-4"]
   ```

2. **Edit Configuration**

   ```hcl
   # vars/dev.tfvars
   validator_node_count = 4  # Decreased from 6
   ```

3. **Review Deletion**

   ```bash
   terraform plan -var-file="vars/dev.tfvars"
   ```

   Expected:

   ```
   Plan: 0 to add, 0 to change, 4 to destroy

   - module.blockchain_chain.kaleido_platform_runtime.validator_runtime[4]
   - module.blockchain_chain.kaleido_platform_service.validator_service[4]
   - module.blockchain_chain.kaleido_platform_runtime.validator_runtime[5]
   - module.blockchain_chain.kaleido_platform_service.validator_service[5]
   ```

4. **Apply Deletion**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

**Result:**

- Deletes `node-validator-5` and `node-validator-6`
- Remaining validators continue consensus
- Network remains operational

**Note:** Terraform destroys highest-indexed nodes first.

---

##### Removing Archive Nodes

**Safe operation** - no impact on consensus.

```hcl
# vars/dev.tfvars
archive_node_count = 0  # Reduced from 2
```

Apply:

```bash
terraform apply -var-file="vars/dev.tfvars"
```

---

#### Removing Services

##### Removing Block Indexer

**Steps:**

1. **Edit Configuration**

   ```hcl
   # vars/dev.tfvars
   enable_block_indexer = false
   ```

2. **Apply Changes**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

**Result:**

- Deletes Block Indexer service and runtime
- Indexed data is lost
- EVM Gateway remains operational

---

##### Removing EVM Gateway

**WARNING:** EVM Gateway is required by:

- Transaction Manager
- Firefly Core
- Block Indexer

**Proper Deletion Order:**

1. **First, disable dependent services:**

   ```hcl
   # vars/dev.tfvars

   # Step 1: Disable Firefly
   enable_firefly = false

   # Step 2: Disable Block Indexer
   enable_block_indexer = false
   ```

2. **Apply to remove dependents:**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

3. **Now safe to disable EVM Gateway:**

   ```hcl
   # vars/dev.tfvars
   enable_evm_gateway = false
   ```

4. **Apply final deletion:**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

---

#### Removing Firefly Stack

##### Removing Individual Firefly Services

**Safe to remove** (no dependents):

```hcl
# vars/dev.tfvars
enable_contract_manager = false  # Safe
```

**Has dependents:**

- `enable_transaction_manager` ← Required by Firefly Core
- `enable_key_manager` ← Required by Transaction Manager

**Proper order for removing TX Manager:**

1. Disable Firefly Core first
2. Then disable Transaction Manager
3. Then disable Key Manager (if needed)

```hcl
# vars/dev.tfvars
enable_firefly_core        = false  # Step 1
enable_transaction_manager = false  # Step 2
enable_key_manager         = false  # Step 3
```

---

##### Removing Entire Firefly Stack

**Steps:**

1. **Edit Configuration**

   ```hcl
   # vars/dev.tfvars
   enable_firefly = false
   ```

2. **Review Deletion**

   ```bash
   terraform plan -var-file="vars/dev.tfvars"
   ```

   Expected: ~20-25 resources to destroy

3. **Apply Deletion**

   ```bash
   terraform apply -var-file="vars/dev.tfvars"
   ```

**Result:**

- Deletes all Firefly services
- Deletes Firefly stack
- **Deletes wallet and keys** - backup first!
- Blockchain network remains intact

---

### Safe Deletion Order

To avoid dependency errors, delete in this order:

1. Firefly Core
2. Contract Manager
3. Transaction Manager
4. Key Manager
5. Block Indexer
6. EVM Gateway
7. Archive Nodes
8. Validator Nodes (maintaining quorum)
9. Network

---

### Alternative: Use Separate Configuration Files

If you want separate configs for blockchain-only and full stack:

```bash
# For blockchain only - use example.tfvars as base
cp vars/example.tfvars vars/blockchain-only.tfvars

# For full stack - use dev.tfvars (already configured)
terraform apply -var-file="vars/dev.tfvars"
```

### Firefly Configuration Options

#### All Services Enabled (Default)

All Firefly components are enabled by default in `vars/firefly.tfvars`.

#### Minimal Configuration

To deploy only core services:

```hcl
enable_firefly              = true
enable_firefly_core         = true
enable_transaction_manager  = true
enable_key_manager          = true
enable_contract_manager     = false
enable_subscriptions        = false
enable_event_listeners      = false
enable_private_data_manager = false
```

#### Custom Service Configuration

You can customize each service with additional configuration:

```hcl
transaction_manager_config = {
  maxInFlight    = 100
  gasOracleMode  = "connector"
}

event_listeners_config = {
  fromBlock        = "latest"
  blocksToFinality = 50
}
```

### View Firefly Deployment

```bash
# View all outputs
terraform output

# View Firefly-specific outputs
terraform output firefly_deployment_summary
terraform output firefly_all_service_ids

# View specific service IDs
terraform output firefly_core_service_id
terraform output firefly_transaction_manager_service_id
```

## Configuration Reference

### Firefly Services

| Service              | Variable                      | Description                     | Default |
| -------------------- | ----------------------------- | ------------------------------- | ------- |
| Firefly Core         | `enable_firefly_core`         | Main orchestration engine       | `true`  |
| Transaction Manager  | `enable_transaction_manager`  | Manages blockchain transactions | `true`  |
| Private Data Manager | `enable_private_data_manager` | Manages private data exchange   | `true`  |
| Key Manager          | `enable_key_manager`          | Cryptographic key management    | `true`  |
| Contract Manager     | `enable_contract_manager`     | Smart contract deployment       | `true`  |
| Subscriptions        | `enable_subscriptions`        | Event subscriptions & webhooks  | `true`  |
| Event Listeners      | `enable_event_listeners`      | Blockchain event monitoring     | `true`  |

### Database Options

```hcl
firefly_database_type = "postgres"  # or "sqlite"
firefly_enable_ipfs   = true        # Enable IPFS for shared storage
```

### Key Manager Types

```hcl
key_manager_type = "FireFlySigner"  # or "HDWalletSigner"
```

## Module Structure

```
.
├── main.tf                    # Root module
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── provider.tf                # Provider configuration
├── terraform.tfvars           # Current configuration
├── modules/
│   ├── chain/                 # Blockchain network module
│   │   ├── main.tf
│   │   ├── nodes.tf
│   │   ├── services.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── firefly/               # Hyperledger Firefly module
│       ├── main.tf            # Firefly services
│       ├── variables.tf       # Firefly variables
│       └── outputs.tf         # Firefly outputs
└── vars/
    ├── example.tfvars         # Blockchain example
    └── firefly.tfvars         # Firefly example
```

## Connecting to Existing Network (Story 11513537)

The Firefly module automatically connects to your existing blockchain network:

```hcl
# In main.tf, the connection is established via:
module "firefly_middleware" {
  network_id             = module.blockchain_chain.blockchain_network_id
  evm_gateway_service_id = module.blockchain_chain.evm_gateway_service_id
}
```

The middleware will use:

- Existing EVM Gateway for blockchain interactions
- Existing Block Indexer for event querying
- Network configuration from Story 11513537

## Best Practices

1. **Always use var-files**: Keep credentials separate from code
2. **Enable all services initially**: Disable only after understanding dependencies
3. **Use PostgreSQL for production**: SQLite is for development only
4. **Enable IPFS**: Required for private data exchange
5. **Tag resources**: Use tags for cost tracking and organization
6. **Review plans**: Always review `terraform plan` before applying

## Troubleshooting

### Firefly Services Not Starting

Check dependencies:

```bash
terraform output evm_gateway_service_id
terraform output blockchain_network_id
```

Ensure the blockchain network is fully deployed before enabling Firefly.

### Configuration Errors

Validate your Terraform configuration:

```bash
terraform validate
terraform fmt -check
```

### Service Dependencies

Services have the following dependencies:

- Firefly Core → EVM Gateway
- Transaction Manager → Firefly Core + EVM Gateway
- Contract Manager → Transaction Manager + Firefly Core
- Event Listeners → Subscriptions + Firefly Core
- Private Data Manager → Firefly Core

## Cleanup

To destroy the Firefly stack only:

```bash
# Set enable_firefly = false in your tfvars
terraform apply -var-file="vars/your-config.tfvars"
```

To destroy everything:

```bash
# Enable force deletion first
terraform apply -var="force_delete_nodes=true" -var-file="vars/your-config.tfvars"

# Then destroy
terraform destroy -var-file="vars/your-config.tfvars"
```

## 🔄 Switching Between Signing Modes

### From HDWallet to Azure Key Vault

```bash
# 1. Add Azure configuration to Vault
export AZURE_CLIENT_SECRET='your-secret'
./vault-store-config-azure-keyvault.sh prod

# 2. Set ARM environment variables
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."

# 3. Apply
make apply ENV=prod
```

Terraform automatically:
- Creates Azure Key Vault module
- Updates Firefly wallet to type `azurekeyvault`
- Removes local key resource

### From Azure Key Vault to HDWallet

```bash
# 1. Update configuration in Vault
vault kv patch secret/kaleido/dev \
  key_manager_type="HDWalletSigner" \
  key_manager_config='{"keystorePath":"/data/keystore"}'

# 2. Apply
make apply ENV=dev
```

Terraform automatically:
- Removes Azure Key Vault module
- Updates Firefly wallet to type `hdwallet`
- Creates local key resource

## 📊 Configuration Comparison

| Feature | HDWallet (Dev) | Azure Key Vault (Prod) |
|---------|----------------|------------------------|
| **Signing Method** | Local HDWallet | Remote HSM signing |
| **Key Storage** | Kaleido platform | Azure Key Vault HSM |
| **Security Level** | Development | FIPS 140-2 Level 3 |
| **Azure Setup** | Not required | Required |
| **Terraform Module** | Azure module NOT created | Azure module created |
| **Best For** | Development/Testing | Production deployments |

## 📖 Documentation

- [PRODUCTION_SETUP_GUIDE.md](PRODUCTION_SETUP_GUIDE.md) - Complete production deployment guide with Azure setup
- [UNIFIED_MAIN_CONFIGURATION.md](docs/UNIFIED_MAIN_CONFIGURATION.md) - Technical details of unified configuration
- [TESTING_RESULTS.md](docs/TESTING_RESULTS.md) - Test results for both HDWallet and Azure Key Vault modes
- [AZURE_VAULT_PARAMETERS.md](docs/AZURE_VAULT_PARAMETERS.md) - Complete Azure parameter reference

## 🎯 Design Principles

1. **Single Source of Truth**: All configuration in HashiCorp Vault
2. **Minimal tfvars**: Only 2 parameters (vault_environment, enable_firefly)
3. **Automatic Mode Detection**: No manual switching required - based on `key_manager_type` in Vault
4. **Conditional Resources**: Azure module created only when `key_manager_type = "AzureKeyVaultSigner"`
5. **Safe Defaults**: lookup() with defaults for optional Azure parameters
6. **Production Ready**: No hardcoded credentials or fake test data

## ✅ Production Readiness

**System Status: FULLY PRODUCTION READY! 🚀**

- ✅ All 49 parameters from Vault
- ✅ Unified main.tf supporting both HDWallet and Azure Key Vault
- ✅ Conditional Azure module creation (`count = 0` or `1`)
- ✅ No hardcoded constants
- ✅ No fake credentials
- ✅ Production-ready Azure provider
- ✅ Complete documentation
- ✅ Security best practices implemented

## 🐛 Troubleshooting

### Vault Connection Refused
```bash
# Check Vault is running
vault status

# Verify environment variables
echo $VAULT_ADDR
echo $VAULT_TOKEN
```

### Azure Provider Authentication Failed
```bash
# Verify ARM environment variables
echo $ARM_SUBSCRIPTION_ID
echo $ARM_TENANT_ID
echo $ARM_CLIENT_ID

# Test Azure login
az login --service-principal \
  --username $ARM_CLIENT_ID \
  --password $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID
```

### Azure Module Created When Not Needed
```bash
# Check key_manager_type in Vault
vault kv get -field=key_manager_type secret/kaleido/dev
# Should be "HDWalletSigner" for dev

# Fix if incorrect
vault kv patch secret/kaleido/dev \
  key_manager_type="HDWalletSigner"
```

## 🤝 Support

For issues related to:
- **Kaleido Platform**: [Kaleido Documentation](https://docs.kaleido.io/)
- **Azure Key Vault**: [Azure Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- **HashiCorp Vault**: [Vault Documentation](https://www.vaultproject.io/docs)
- **Terraform**: [Terraform Documentation](https://www.terraform.io/docs)

## 📝 License

This configuration is provided as-is for use with Kaleido blockchain platform.
