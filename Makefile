# Makefile for Terraform Kaleido deployment with HashiCorp Vault
# Usage: make <target> ENV=<environment>
# Example: make plan ENV=dev

.PHONY: help init plan apply destroy validate fmt clean vault-check

# Default environment
ENV ?= dev

# Vault configuration (can be overridden by environment variables)
export VAULT_ADDR ?= http://127.0.0.1:8200
export VAULT_TOKEN ?= root

help: ## Show this help message
	@echo "Usage: make <target> ENV=<environment>"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Available environments: dev, sit, prod"
	@echo ""
	@echo "Examples:"
	@echo "  make vault-check ENV=dev  # Check Vault connection"
	@echo "  make plan ENV=dev         # Plan with Vault credentials"
	@echo "  make apply ENV=prod       # Apply with Vault credentials"
	@echo ""
	@echo "Required environment variables:"
	@echo "  VAULT_ADDR  - Vault server address"
	@echo "  VAULT_TOKEN - Vault authentication token"
	@echo ""
	@echo "To store credentials in Vault:"
	@echo "  vault kv put secret/kaleido/dev api_endpoint=... username=... api_key=... environment_id=..."

vault-check: ## Check Vault connection and credentials
	@echo "Checking Vault connection..."
	@if [ -z "$$VAULT_ADDR" ]; then \
		echo "VAULT_ADDR is not set"; \
		echo "Set it with: export VAULT_ADDR=http://127.0.0.1:8200"; \
		exit 1; \
	fi
	@if [ -z "$$VAULT_TOKEN" ]; then \
		echo "VAULT_TOKEN is not set"; \
		echo "Set it with: export VAULT_TOKEN=<your-token>"; \
		exit 1; \
	fi
	@vault status > /dev/null 2>&1 && echo "Connected to Vault at $$VAULT_ADDR" || (echo "Cannot connect to Vault"; exit 1)
	@vault kv get secret/kaleido/$(ENV) > /dev/null 2>&1 && echo "Credentials found for $(ENV)" || (echo "Credentials not found for $(ENV)"; exit 1)

init: ## Initialize Terraform
	@$(MAKE) vault-check ENV=$(ENV)
	terraform init

plan: ## Show Terraform plan
	@$(MAKE) vault-check ENV=$(ENV)
	terraform plan -var-file=vars/$(ENV).tfvars

apply: ## Apply Terraform changes
	@$(MAKE) vault-check ENV=$(ENV)
	terraform apply -var-file=vars/$(ENV).tfvars

apply-auto: ## Apply Terraform changes without confirmation
	@$(MAKE) vault-check ENV=$(ENV)
	terraform apply -var-file=vars/$(ENV).tfvars -auto-approve

destroy: ## Destroy Terraform resources
	@$(MAKE) vault-check ENV=$(ENV)
	terraform destroy -var-file=vars/$(ENV).tfvars

destroy-auto: ## Destroy Terraform resources without confirmation
	@$(MAKE) vault-check ENV=$(ENV)
	terraform destroy -var-file=vars/$(ENV).tfvars -auto-approve

validate: ## Validate Terraform configuration
	terraform validate

fmt: ## Format Terraform files
	terraform fmt -recursive

clean: ## Clean Terraform files
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate.backup
	rm -f tfplan

state-list: ## List resources in Terraform state
	terraform state list

state-show: ## Show specific resource (use RESOURCE=xxx)
	terraform state show $(RESOURCE)

output: ## Show Terraform outputs
	terraform output

refresh: ## Refresh Terraform state
	@$(MAKE) vault-check ENV=$(ENV)
	terraform refresh -var-file=vars/$(ENV).tfvars

# Environment-specific shortcuts
dev-plan: ## Quick plan for dev environment
	@$(MAKE) plan ENV=dev

dev-apply: ## Quick apply for dev environment
	@$(MAKE) apply ENV=dev

sit-plan: ## Quick plan for sit environment
	@$(MAKE) plan ENV=sit

sit-apply: ## Quick apply for sit environment
	@$(MAKE) apply ENV=sit

prod-plan: ## Quick plan for prod environment
	@$(MAKE) plan ENV=prod

prod-apply: ## Quick apply for prod environment
	@$(MAKE) apply ENV=prod
