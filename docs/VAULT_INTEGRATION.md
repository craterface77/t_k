# HashiCorp Vault Integration Guide

## Overview

This project uses **HashiCorp Vault** for secure credential management. All sensitive Kaleido credentials are stored in Vault and retrieved dynamically by Terraform during execution.

---

## Table of Contents

1. [Why Vault?](#why-vault)
2. [Architecture](#architecture)
3. [Quick Start](#quick-start)
4. [Vault Setup](#vault-setup)
5. [Usage](#usage)
6. [CI/CD Integration](#cicd-integration)
7. [Troubleshooting](#troubleshooting)
8. [Security Best Practices](#security-best-practices)

---

## Why Vault?

| Feature                 | Vault                     | .env Files                   |
| ----------------------- | ------------------------- | ---------------------------- |
| **Centralized Secrets** | ✅ Single source of truth | ❌ Scattered across machines |
| **Audit Logging**       | ✅ Complete access logs   | ❌ No tracking               |
| **Automatic Rotation**  | ✅ Supported              | ❌ Manual only               |
| **Dynamic Secrets**     | ✅ TTL-based              | ❌ Static                    |
| **Access Control**      | ✅ Granular policies      | ❌ File permissions only     |
| **Encryption at Rest**  | ✅ Always encrypted       | ⚠️ Depends on filesystem     |
| **Team Collaboration**  | ✅ Easy sharing           | ❌ Difficult & insecure      |

---

## Architecture

```
┌─────────────────┐
│  Terraform      │
│                 │
│  1. Requests    │
│     credentials │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Vault Server   │
│                 │
│  2. Validates   │
│     token       │
│                 │
│  3. Returns     │
│     secrets     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Kaleido API    │
│                 │
│  4. Terraform   │
│     provisions  │
│     resources   │
└─────────────────┘
```

**Secret Storage Structure:**

```
secret/
└── kaleido/
    ├── dev/
    │   ├── api_endpoint
    │   ├── username
    │   ├── api_key
    │   └── environment_id
    ├── sit/
    │   └── ...
    └── prod/
        └── ...
```

---

## Quick Start

### 1. Install Vault CLI

```bash
# macOS
brew install vault

# Linux
wget https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
unzip vault_1.15.0_linux_amd64.zip
sudo mv vault /usr/local/bin/

# Verify installation
vault version
```

### 2. Start Vault Server (Development)

```bash
# Start dev server (NOT for production!)
vault server -dev

# In another terminal, set environment variables
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='<root-token-from-output>'
```

### 3. Store Credentials

```bash
# Store your Kaleido credentials in Vault
vault kv put secret/kaleido/dev \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="your-username" \
  api_key="your-api-key" \
  environment_id="e:your-env-id"
```

### 4. Run Terraform

```bash
# Export Vault credentials
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='your-vault-token'

# Run Terraform
make plan ENV=dev
make apply ENV=dev
```

---

## Vault Setup

### Option 1: Development Server (Quick Start)

**⚠️ WARNING: Dev server is NOT secure! Use only for testing.**

```bash
# Start dev server
vault server -dev

# Output will show root token:
# Root Token: hvs.xxxxxxxxxxxxx

# Set environment variables
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='hvs.xxxxxxxxxxxxx'

# Enable KV v2 secrets engine (if not already enabled)
vault secrets enable -path=secret kv-v2

# Add credentials
vault kv put secret/kaleido/dev \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="test-user" \
  api_key="your-api-key-here" \
  environment_id="e:env123"
```

### Option 2: Production Server

For production, use Vault in server mode with TLS:

```bash
# 1. Create Vault configuration file
cat > vault-config.hcl <<EOF
storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/etc/vault/tls/vault.crt"
  tls_key_file  = "/etc/vault/tls/vault.key"
}

api_addr = "https://vault.example.com:8200"
cluster_addr = "https://vault.example.com:8201"
ui = true
EOF

# 2. Start Vault
vault server -config=vault-config.hcl

# 3. Initialize Vault (first time only)
vault operator init

# Save the unseal keys and root token securely!

# 4. Unseal Vault (required after every restart)
vault operator unseal <key-1>
vault operator unseal <key-2>
vault operator unseal <key-3>
```

### Option 3: HCP Vault (Managed Cloud)

```bash
# 1. Create account at https://portal.cloud.hashicorp.com

# 2. Create Vault cluster

# 3. Get Vault address and admin token

# 4. Configure environment
export VAULT_ADDR='https://your-vault.vault.hashicorp.cloud:8200'
export VAULT_TOKEN='your-admin-token'
export VAULT_NAMESPACE='admin'

# 5. Setup secrets
vault kv put secret/kaleido/dev \
  api_endpoint="..." \
  username="..." \
  api_key="..." \
  environment_id="..."
```

---

## Usage

### Store Credentials

```bash
# For development environment
vault kv put secret/kaleido/dev \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="dev-user@example.com" \
  api_key="dev-api-key-xxxxx" \
  environment_id="e:dev123"

# For SIT environment
vault kv put secret/kaleido/sit \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="sit-user@example.com" \
  api_key="sit-api-key-xxxxx" \
  environment_id="e:sit123"

# For production environment
vault kv put secret/kaleido/prod \
  api_endpoint="https://account1.platform.ape1-c1.scb.kaleido.cloud" \
  username="prod-user@example.com" \
  api_key="prod-api-key-xxxxx" \
  environment_id="e:prod123"
```

### Retrieve Credentials

```bash
# View all secrets for dev
vault kv get secret/kaleido/dev

# Get specific field
vault kv get -field=api_key secret/kaleido/dev

# List all environments
vault kv list secret/kaleido
```

### Update Credentials

```bash
# Update a single field
vault kv patch secret/kaleido/dev api_key="new-api-key"

# Replace all fields
vault kv put secret/kaleido/dev \
  api_endpoint="..." \
  username="..." \
  api_key="new-key" \
  environment_id="..."
```

### Delete Credentials

```bash
# Soft delete (can be recovered)
vault kv delete secret/kaleido/dev

# Permanent delete
vault kv destroy secret/kaleido/dev
```

### Run Terraform

```bash
# Set Vault credentials
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='your-token'

# Using Makefile (recommended)
make vault-check ENV=dev    # Verify Vault connection
make plan ENV=dev           # Plan deployment
make apply ENV=dev          # Apply changes

# Or directly with Terraform
terraform init
terraform plan -var-file=vars/dev.tfvars
terraform apply -var-file=vars/dev.tfvars
```

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Install Vault CLI
        run: |
          wget -q https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
          unzip vault_1.15.0_linux_amd64.zip
          sudo mv vault /usr/local/bin/

      - name: Configure Vault
        env:
          VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
          VAULT_TOKEN: ${{ secrets.VAULT_TOKEN }}
        run: |
          vault status
          vault kv get secret/kaleido/prod

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        env:
          VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
          VAULT_TOKEN: ${{ secrets.VAULT_TOKEN }}
        run: terraform plan -var-file=vars/prod.tfvars

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        env:
          VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
          VAULT_TOKEN: ${{ secrets.VAULT_TOKEN }}
        run: terraform apply -var-file=vars/prod.tfvars -auto-approve
```

### GitLab CI

```yaml
deploy:
  image: hashicorp/terraform:latest
  before_script:
    - apk add --no-cache vault
    - export VAULT_ADDR=$VAULT_ADDR
    - export VAULT_TOKEN=$VAULT_TOKEN
  script:
    - terraform init
    - terraform plan -var-file=vars/prod.tfvars
    - terraform apply -var-file=vars/prod.tfvars -auto-approve
  variables:
    VAULT_ADDR: $VAULT_ADDR
    VAULT_TOKEN: $VAULT_TOKEN
```

---

## Troubleshooting

### Cannot Connect to Vault

**Error:** `Error making API request`

**Solution:**

```bash
# Check if Vault is running
vault status

# Verify VAULT_ADDR
echo $VAULT_ADDR

# Test connection
curl $VAULT_ADDR/v1/sys/health
```

### Invalid Token

**Error:** `permission denied`

**Solution:**

```bash
# Check token validity
vault token lookup

# Renew token if needed
vault token renew

# Or get a new token
vault login
```

### Secrets Not Found

**Error:** `secret not found at path`

**Solution:**

```bash
# List available paths
vault kv list secret/kaleido

# Verify path structure
vault kv get secret/kaleido/dev

# Re-create secret if needed
vault kv put secret/kaleido/dev api_endpoint="..." username="..." api_key="..." environment_id="..."
```

### Terraform Cannot Read Secrets

**Error:** `failed to read from Vault`

**Solution:**

```bash
# Check Vault provider configuration in provider.tf
# Ensure VAULT_ADDR and VAULT_TOKEN are set
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='your-token'

# Verify Terraform can access Vault
terraform console
> data.vault_kv_secret_v2.kaleido_credentials
```

---

## Security Best Practices

### 1. Use Production-Grade Vault

- ✅ Use TLS for all connections
- ✅ Enable audit logging
- ✅ Use AppRole or other auth methods (not root token)
- ✅ Implement secret rotation policies
- ❌ Never use dev server in production

### 2. Token Management

```bash
# Create limited-scope token for Terraform
vault token create \
  -policy=terraform-kaleido \
  -ttl=1h \
  -renewable

# Instead of using root token
```

### 3. Access Policies

Create a policy file `terraform-kaleido-policy.hcl`:

```hcl
# Allow reading Kaleido secrets
path "secret/data/kaleido/*" {
  capabilities = ["read", "list"]
}

# Allow listing secret paths
path "secret/metadata/kaleido/*" {
  capabilities = ["list"]
}
```

Apply the policy:

```bash
vault policy write terraform-kaleido terraform-kaleido-policy.hcl

# Create token with this policy
vault token create -policy=terraform-kaleido
```

### 4. Audit Logging

```bash
# Enable audit logging
vault audit enable file file_path=/var/log/vault-audit.log

# View audit logs
tail -f /var/log/vault-audit.log
```

### 5. Secret Rotation

```bash
# Rotate API keys regularly
vault kv put secret/kaleido/prod \
  api_key="new-rotated-key-xxxxx" \
  # ... other fields

# Update timestamp
vault kv metadata put -custom-metadata=rotated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  secret/kaleido/prod
```

---

## Additional Resources

- **Vault Documentation:** https://www.vaultproject.io/docs
- **Vault Terraform Provider:** https://registry.terraform.io/providers/hashicorp/vault
- **HCP Vault (Managed):** https://cloud.hashicorp.com/products/vault
- **Vault Tutorials:** https://learn.hashicorp.com/vault

---

## Support

For issues or questions:

1. Check this documentation
2. Review Vault logs: `vault status` and audit logs
3. Test connectivity: `make vault-check ENV=dev`
4. Contact DevOps team
