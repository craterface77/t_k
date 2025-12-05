# Kaleido Blockchain Infrastructure - Terraform

Professional modular Terraform configuration for deploying blockchain infrastructure on Kaleido Platform.

## Quick Start

### 1. Configure Variables

Create your environment configuration:

```bash
cp vars/example.tfvars vars/dev.tfvars
```

Edit `vars/dev.tfvars` and update:

```hcl
# REQUIRED: Your Kaleido credentials
kaleido_platform_api      = "https://account1.platform.ape1-c1.scb.kaleido.cloud"
kaleido_platform_username = "your-username"
kaleido_platform_password = "your-api-key"

# Environment
environment_id   = "e:fryskwx4xf"
environment_name = "dlt-da-01"

# Network configuration
network_name = "my-blockchain-network"
```

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
```
