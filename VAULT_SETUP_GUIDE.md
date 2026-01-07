# Vault Setup Guide

## ✅ Vault Integration Complete!

All `.env` files have been replaced with **HashiCorp Vault** for secure credential management.

---

## 🎯 What You Need to Do

### 1. Install Vault CLI

```bash
# macOS
brew install vault

# Linux (Ubuntu/Debian)
wget https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
unzip vault_1.15.0_linux_amd64.zip
sudo mv vault /usr/local/bin/

# Verify installation
vault version
```

### 2. Start Vault Server (Development)

```bash
# Terminal 1: Start Vault dev server
vault server -dev

# IMPORTANT: Save the Root Token from the output!
# It will look like: Root Token: hvs.xxxxxxxxxxxxxx
```

### 3. Configure Vault

In a **new terminal**:

```bash
# Set Vault address
export VAULT_ADDR='http://127.0.0.1:8200'

# Set Vault token (use the Root Token from step 2)
export VAULT_TOKEN='hvs.xxxxxxxxxxxxxx'

# Verify connection
vault status
```

### 4. Store ALL Configuration in Vault

```bash
# Option 1: Use the provided script (recommended)
./vault-store-config.sh dev

# Option 2: Manual command (store all variables)
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

### 5. Verify Secrets

```bash
# List all environments
vault kv list secret/kaleido

# View dev credentials
vault kv get secret/kaleido/dev

# Check Vault connection
make vault-check ENV=dev
```

### 6. Deploy with Terraform

```bash
# Make sure VAULT_ADDR and VAULT_TOKEN are set
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='hvs.xxxxxxxxxxxxxx'

# Initialize Terraform
make init ENV=dev

# Plan deployment
make plan ENV=dev

# Apply changes
make apply ENV=dev
```

---

## 🔑 What Gets Stored in Vault

ALL configuration from dev.tfvars is now stored in Vault:

**Credentials:**

- API endpoint, username, API key, environment ID

**Network Configuration:**

- Network name, type, consensus algorithm, block period

**Node Configuration:**

- Validator/archive node counts, sizes, naming

**Service Configuration:**

- Block indexer, EVM gateway settings

**Firefly Middleware:**

- Stack configuration, core settings
- Transaction manager, key manager, contract manager
- Complex configurations (stored as JSON)

**Quick Setup:**

```bash
# Use the script to store everything at once
./vault-store-config.sh dev
```

---

## 📋 Quick Reference

### Daily Commands

```bash
# Before starting work
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='your-token'

# Check Vault
make vault-check ENV=dev

# Deploy
make plan ENV=dev
make apply ENV=dev
```

### Vault Commands

```bash
# List environments
vault kv list secret/kaleido

# View secrets
vault kv get secret/kaleido/dev

# Update a field
vault kv patch secret/kaleido/dev api_key="new-key"

# Delete secrets
vault kv delete secret/kaleido/dev
```

### Terraform Commands

```bash
make init ENV=dev         # Initialize
make plan ENV=dev         # Preview changes
make apply ENV=dev        # Apply changes
make destroy ENV=dev      # Destroy resources
make output              # Show outputs
make validate            # Validate configuration
```

---

## 🆘 Troubleshooting

### "Cannot connect to Vault"

```bash
# Check if Vault is running
vault status

# Verify VAULT_ADDR
echo $VAULT_ADDR
# Should be: http://127.0.0.1:8200

# Restart Vault if needed
vault server -dev
```

### "Permission denied"

```bash
# Check your token
vault token lookup

# Verify VAULT_TOKEN is set
echo $VAULT_TOKEN

# If token expired, restart Vault and get new token
```

### "Secret not found"

```bash
# Check what secrets exist
vault kv list secret/kaleido

# Re-create secrets
vault kv put secret/kaleido/dev \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="test-oleh2" \
  api_key="ba95c7c2-43b4-4690-8689-11f3410027a16346625c-13e6-4be3-b1a9-f069c218d31e" \
  environment_id="e:fryskwx4xf"
```

### Terraform errors

```bash
# Ensure environment variables are set
echo $VAULT_ADDR
echo $VAULT_TOKEN

# Verify secrets exist
vault kv get secret/kaleido/dev

# Check Terraform can connect
make vault-check ENV=dev
```

---

## 📚 Documentation

- **[docs/VAULT_INTEGRATION.md](docs/VAULT_INTEGRATION.md)** - Complete guide
- **[QUICK_START.md](QUICK_START.md)** - 5-minute setup
- **[CHANGELOG_VAULT.md](CHANGELOG_VAULT.md)** - What changed
- **[README.md](README.md)** - Main documentation

---

## ⚠️ Important Notes

1. **Dev server is NOT secure** - Use only for testing
2. **Save your Root Token** - You'll need it every time
3. **Export variables every session**:
   ```bash
   export VAULT_ADDR='http://127.0.0.1:8200'
   export VAULT_TOKEN='your-token'
   ```
4. **For production** - Use production Vault with TLS

---

## ✅ Checklist

Before you can deploy:

- [ ] Vault CLI installed
- [ ] Vault server running (`vault server -dev`)
- [ ] VAULT_ADDR set (`export VAULT_ADDR=...`)
- [ ] VAULT_TOKEN set (`export VAULT_TOKEN=...`)
- [ ] Credentials stored (`vault kv put ...`)
- [ ] Secrets verified (`vault kv get secret/kaleido/dev`)
- [ ] Connection checked (`make vault-check ENV=dev`)

Once all checked:

- [ ] Run `make plan ENV=dev`
- [ ] Run `make apply ENV=dev`

---

## 🎉 You're All Set!

Once Vault is configured, you can deploy with:

```bash
make apply ENV=dev
```

For questions or issues, check the documentation or run `make help`.
