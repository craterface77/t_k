# Kaleido Blockchain Infrastructure - Terraform

Professional modular Terraform configuration for deploying blockchain infrastructure with Hyperledger Firefly middleware on Kaleido Platform.

## Overview

This repository contains Terraform scripts to deploy:

- **Blockchain Network** (Hyperledger Besu/GoQuorum)
  - Validator nodes
  - Archive nodes
  - EVM Gateway
  - Block Indexer
- **Hyperledger Firefly Middleware** (Optional)
  - Firefly Core
  - Transaction Manager
  - Private Data Manager
  - Key Manager
  - Contract Manager
  - Subscriptions
  - Event Listeners

All services are deployed in a single, managed stack for easy configuration and maintenance.

## Quick Start - Unified Deployment (Blockchain + Firefly)

The `vars/dev.tfvars` file contains a **unified configuration** that deploys both blockchain and Firefly middleware together.

### 1. Review Configuration

```bash
# The dev.tfvars already includes both blockchain and Firefly settings
cat vars/dev.tfvars
```

**Firefly is enabled by default** with all services configured:

- Firefly Core
- Transaction Manager
- Private Data Manager
- Key Manager
- Contract Manager
- Subscriptions
- Event Listeners

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan -var-file="vars/dev.tfvars"
```

### 4. Deploy

```bash
terraform apply -var-file="vars/dev.tfvars"
```

### 5. View Outputs

```bash
terraform output

terraform output firefly_deployment_summary

terraform output firefly_all_service_ids
```

## Customizing Firefly Configuration

### Disable Firefly (Deploy Blockchain Only)

Edit `vars/dev.tfvars` and set:

```hcl
enable_firefly = false
```

Then apply:

```bash
terraform apply -var-file="vars/dev.tfvars"
```

### Enable/Disable Individual Services

In `vars/dev.tfvars`, toggle individual services:

```hcl
enable_firefly = true

# Individual service controls
enable_firefly_core         = true
enable_transaction_manager  = true
enable_private_data_manager = false  # Disable this service
enable_key_manager          = true
enable_contract_manager     = false  # Disable this service
enable_subscriptions        = true
enable_event_listeners      = true
```

## Complete Parameter Reference from dev.tfvars

| Parameter                         | Can Change? | Notes                          |
| --------------------------------- | ----------- | ------------------------------ |
| `environment_name`                | YES         | Label only                     |
| `network_name`                    | YES         | Updates in-place               |
| `network_type`                    | NO          | Not tested                     |
| `consensus_algorithm`             | YES         | Updates in-place               |
| `block_period_seconds`            | YES         | Updates in-place               |
| `validator_node_count`            | PARTIAL     | Adds/removes nodes             |
| `archive_node_count`              | PARTIAL     | Adds/removes nodes             |
| `validator_node_size`             | NO          | Ignored                        |
| `archive_node_size`               | NO          | Ignored                        |
| `node_name_prefix`                | NO          | Renames all nodes              |
| `chain_infrastructure_stack_name` | NO          | Recreates stack (24 destroy)   |
| `enable_block_indexer`            | YES         | Creates/destroys service       |
| `enable_evm_gateway`              | YES         | Creates/destroys service       |
| `block_indexer_name`              | YES         | Updates in-place               |
| `evm_gateway_name`                | YES         | Updates in-place               |
| `enable_firefly`                  | YES         | Creates/destroys stack         |
| `firefly_stack_name`              | NO          | Recreates Firefly (24 destroy) |
| `enable_firefly_core`             | YES         | Creates/destroys service       |
| `firefly_core_name`               | YES         | Updates in-place               |
| `enable_transaction_manager`      | YES         | Creates/destroys service       |
| `transaction_manager_name`        | NO          | Not tested                     |
| `transaction_manager_config.*`    | YES         | Updates runtime                |
| `enable_key_manager`              | YES         | Creates/destroys service       |
| `key_manager_name`                | NO          | Not tested                     |
| `key_manager_type`                | YES         | Updates in-place               |
| `key_manager_config.*`            | YES         | Updates runtime                |
| `enable_contract_manager`         | YES         | Creates/destroys service       |
| `contract_manager_name`           | NO          | Not tested                     |
| `contract_manager_config.*`       | YES         | Updates runtime                |
| `firefly_database_type`           | NO          | Data loss                      |

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

## Support

For issues or questions:

1. Check the Kaleido documentation
2. Review Terraform logs: `terraform show`
3. Validate configuration: `terraform validate`
