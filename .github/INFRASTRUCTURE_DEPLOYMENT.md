# GitHub Actions Infrastructure Deployment

This document explains how to set up and use the GitHub Actions workflow for deploying Azure infrastructure via Terraform.

## Prerequisites

1. **Azure Service Principal with OIDC** - For authentication to Azure
2. **Azure Storage Account** - For Terraform state storage
3. **GitHub Repository Variables and Secrets** - For configuration

## Setup Instructions

### 1. Create Azure Service Principal with OIDC

Run these commands in Azure CLI:

```bash
# Set variables
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP_NAME="your-resource-group"
REPO_NAME="your-github-username/your-repo-name"

# Create the service principal
az ad sp create-for-rbac \
  --name "sp-terraform-github-actions" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth

# Get the Application ID from the output above
APP_ID="the-appId-from-output-above"

# Create federated credentials for GitHub Actions
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$REPO_NAME':ref:refs/heads/main",
    "description": "GitHub Actions Main Branch",
    "audiences": ["api://AzureADTokenExchange"]
  }'

az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$REPO_NAME':pull_request",
    "description": "GitHub Actions Pull Requests",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### 2. Create Terraform State Storage

```bash
# Create resource group for Terraform state
az group create \
  --name "rg-terraform-state" \
  --location "Canada Central"

# Create storage account
az storage account create \
  --name "stterraformstate$(date +%s)" \
  --resource-group "rg-terraform-state" \
  --location "Canada Central" \
  --sku "Standard_LRS" \
  --encryption-services blob

# Create container
az storage container create \
  --name "tfstate" \
  --account-name "your-storage-account-name"
```

### 3. Configure GitHub Repository Variables

Go to your GitHub repository → Settings → Secrets and variables → Actions → Variables tab:

#### Required Variables:

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `AZURE_CLIENT_ID` | Service Principal Application ID | `12345678-1234-1234-1234-123456789012` |
| `AZURE_TENANT_ID` | Azure Tenant ID | `87654321-4321-4321-4321-210987654321` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `11111111-2222-3333-4444-555555555555` |
| `TERRAFORM_STATE_RG` | Resource group for Terraform state | `rg-terraform-state` |
| `TERRAFORM_STATE_STORAGE` | Storage account name for state | `stterraformstate123456` |
| `TERRAFORM_STATE_CONTAINER` | Container name for state | `tfstate` |
| `RESOURCE_GROUP_NAME` | Target resource group name | `rg-nr-permitting-dev` |
| `RESOURCE_GROUP_LOCATION` | Azure region | `canadacentral` |
| `EXISTING_VNET_RG` | Existing VNet resource group | `rg-networking` |
| `EXISTING_VNET_NAME` | Existing VNet name | `vnet-hub` |
| `APIM_SUBNET_PREFIX` | APIM subnet CIDR | `10.0.1.0/24` |
| `APP_SERVICE_SUBNET_PREFIX` | App Service subnet CIDR | `10.0.2.0/24` |
| `PRIVATEENDPOINT_SUBNET_PREFIX` | Private endpoint subnet CIDR | `10.0.3.0/24` |
| `POSTGRESQL_ADMIN_USERNAME` | PostgreSQL admin username | `pgsqladmin` |
| `APIM_PUBLISHER_EMAIL` | APIM publisher email | `admin@yourcompany.com` |
| `APIM_PUBLISHER_NAME` | APIM publisher name | `Your Company` |
| `GHCR_USERNAME` | GitHub Container Registry username | `your-github-username` |

#### Required Secrets:

Go to Secrets tab:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `GHCR_TOKEN` | GitHub Personal Access Token for GHCR | `ghp_xxxxxxxxxxxxxxxxxxxx` |

### 4. Configure GitHub Environments (Optional but Recommended)

Go to your repository → Settings → Environments

Create environments for:
- `dev`
- `staging` 
- `prod`

For each environment, you can:
- Set environment-specific variables
- Add protection rules (require reviews for prod)
- Configure deployment restrictions

## Workflow Usage

### Automatic Triggers

1. **Pull Request** - Automatically runs `terraform plan` and comments results
2. **Push to main** - Automatically runs `terraform apply` after successful plan
3. **Manual Dispatch** - Allows manual execution with choice of action

### Manual Execution

1. Go to Actions tab in your GitHub repository
2. Select "Deploy Infrastructure" workflow
3. Click "Run workflow"
4. Choose:
   - **Action**: `plan`, `apply`, or `destroy`
   - **Environment**: `dev`, `staging`, or `prod`

### Workflow Jobs

1. **terraform-check** - Validates Terraform code formatting and syntax
2. **terraform-plan** - Creates execution plan (runs on PRs and manual plan)
3. **terraform-apply** - Applies changes (runs on main branch push or manual apply)
4. **terraform-destroy** - Destroys infrastructure (manual only)

## Terraform Backend Configuration

The workflow automatically configures the Terraform backend with:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate123456"
    container_name       = "tfstate"
    key                  = "dev.tfstate"  # Environment-specific
  }
}
```

## Security Features

- **OIDC Authentication** - No long-lived secrets for Azure authentication
- **Environment Protection** - Can require approvals for production deployments
- **Sensitive Variables** - Terraform sensitive values are properly masked
- **Plan Artifacts** - Plans are stored securely between jobs

## Troubleshooting

### Authentication Issues
- Verify service principal has correct permissions
- Check federated credential configuration
- Ensure OIDC is properly configured

### State Issues
- Verify storage account and container exist
- Check access permissions to storage account
- Ensure container name and key are correct

### Variable Issues
- Double-check all required variables are set
- Verify variable names match exactly (case-sensitive)
- Check environment-specific variables if using environments

## Best Practices

1. **Use Environments** - Separate dev/staging/prod with protection rules
2. **Review Plans** - Always review terraform plans before applying
3. **State Management** - Use separate state files per environment
4. **Secrets Management** - Use GitHub secrets for sensitive values
5. **Branch Protection** - Require PR reviews before merging to main
