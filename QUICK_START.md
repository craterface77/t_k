# Quick Start Guide - HashiCorp Vault

## 🚀 5-Minute Setup with Vault

### Step 1: Install Vault (1 minute)

```bash
# macOS
brew install vault

# Linux
wget https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
unzip vault_1.15.0_linux_amd64.zip
sudo mv vault /usr/local/bin/

# Verify
vault version
```

### Step 2: Start Vault (1 minute)

```bash
# Start development server
vault server -dev

# Copy the Root Token from output!
# Output looks like:
# Root Token: hvs.xxxxxxxxxxxxxx
```

### Step 3: Store ALL Configuration (2 minutes)

In **another terminal**:

```bash
# Set Vault address
export VAULT_ADDR='http://127.0.0.1:8200'

# Set Vault token (use token from Step 2)
export VAULT_TOKEN='hvs.xxxxxxxxxxxxxx'

# Store ALL configuration (credentials + network + nodes + services)
./vault-store-config.sh dev

# Or manually with vault kv put (see VAULT_ALL_CONFIG.md for full command)
```

### Step 4: Deploy (1 minute)

```bash
# Deploy to dev
make plan ENV=dev
make apply ENV=dev
```

---

## 📋 Common Commands

| Task                   | Command                           |
| ---------------------- | --------------------------------- |
| Store configuration    | `./vault-store-config.sh dev`     |
| Check Vault connection | `make vault-check ENV=dev`        |
| Initialize Terraform   | `make init ENV=dev`               |
| Preview changes        | `make plan ENV=dev`               |
| Apply changes          | `make apply ENV=dev`              |
| View outputs           | `make output`                     |
| Destroy resources      | `make destroy ENV=dev`            |
| View stored config     | `vault kv get secret/kaleido/dev` |

---

## 🌍 Multiple Environments

### Development

```bash
# Store all configuration
./vault-store-config.sh dev

# Deploy
make apply ENV=dev
```

### SIT

```bash
# Store all SIT configuration (edit script or use manual command)
# See VAULT_ALL_CONFIG.md for full command
vault kv put secret/kaleido/sit ...

# Deploy
make apply ENV=sit
```

### Production

```bash
# Store all production configuration
# See VAULT_ALL_CONFIG.md for full command
vault kv put secret/kaleido/prod ...

# Deploy
make apply ENV=prod
```

---

## 🔧 Manual Vault Commands

```bash
# View all environments
vault kv list secret/kaleido

# Get all configuration for environment
vault kv get secret/kaleido/dev

# Update a single field
vault kv patch secret/kaleido/dev network_name="new-network"

# Update all configuration
./vault-store-config.sh dev

# Delete configuration
vault kv delete secret/kaleido/dev
```

---

## 📁 Project Structure

```
.
├── vault.tf                      # Reads ALL config from Vault
├── vault-store-config.sh         # Script to store all configuration
├── provider.tf                   # Vault & Kaleido providers
├── variables.tf                  # Vault configuration variables
├── main.tf                       # Uses Vault locals instead of vars
├── vars/dev.tfvars               # Optional overrides only
├── Makefile                      # Task shortcuts with Vault checks
└── docs/
    ├── VAULT_INTEGRATION.md      # Full Vault documentation
    └── VAULT_ALL_CONFIG.md       # Storing all config in Vault
```

---

## ⚠️ Important Notes

1. **Dev server is NOT secure** - Use only for testing
2. **Save your Vault token** - You'll need it for every session
3. **Use production Vault** for real deployments
4. **Enable audit logging** in production

---

## 📚 Need More Help?

- **Storing all config:** [VAULT_ALL_CONFIG.md](docs/VAULT_ALL_CONFIG.md)
- **Detailed Vault guide:** [docs/VAULT_INTEGRATION.md](docs/VAULT_INTEGRATION.md)
- **Setup guide:** [VAULT_SETUP_GUIDE.md](VAULT_SETUP_GUIDE.md)
- **Full README:** [README.md](README.md)

---

## 🆘 Troubleshooting

### "Cannot connect to Vault"

```bash
# Check if Vault is running
vault status

# Verify VAULT_ADDR
echo $VAULT_ADDR

# Should be: http://127.0.0.1:8200
```

### "Permission denied"

```bash
# Check your token
vault token lookup

# Verify VAULT_TOKEN is set
echo $VAULT_TOKEN
```

### "Secret not found"

```bash
# List available configurations
vault kv list secret/kaleido

# Check specific path
vault kv get secret/kaleido/dev

# Re-create if needed
./vault-store-config.sh dev
```

---

## ✅ Production Checklist

Before using Vault in production:

- [ ] Use production Vault server (not dev mode)
- [ ] Enable TLS/HTTPS
- [ ] Setup audit logging
- [ ] Create limited-scope tokens (not root)
- [ ] Implement access policies
- [ ] Setup automatic backups
- [ ] Document recovery procedures

See [docs/VAULT_INTEGRATION.md](docs/VAULT_INTEGRATION.md) for production setup.

---

## 🎯 Next Steps

1. ✅ Setup Vault and store all configuration
2. ✅ Deploy to dev environment
3. ⏭️ Test the deployment
4. ⏭️ Setup SIT and Prod configurations in Vault
5. ⏭️ Configure CI/CD pipeline
6. ⏭️ Setup production Vault

---

## ✅ That's It!

You're ready to deploy with Vault storing ALL your configuration. For more details, check [VAULT_ALL_CONFIG.md](docs/VAULT_ALL_CONFIG.md).
