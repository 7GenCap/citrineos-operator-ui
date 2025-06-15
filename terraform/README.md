# Terraform Infrastructure for CitrineOS Operator UI

This Terraform configuration automates the creation of Google Cloud Platform resources needed for deploying the CitrineOS Operator UI via GitHub Actions.

## What it creates

- **Service Account**: `github-actions` for CI/CD pipeline
- **IAM Roles**: Required permissions for Cloud Run, Cloud Build, and Storage
- **API Enablement**: Enables necessary GCP APIs
- **Service Account Key**: For GitHub Actions authentication

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated
3. A GCP project with billing enabled

## Usage

### 1. Setup

```bash
# Clone and navigate to terraform directory
cd terraform

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your project details
# Update project_id and region
```

### 2. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 3. Get the Service Account Key

```bash
# Extract the service account key (base64 encoded)
terraform output -raw service_account_key > key.json.b64

# Decode the key
base64 -d key.json.b64 > key.json

# The key.json file can now be used as GCP_SA_KEY in GitHub Secrets
```

### 4. GitHub Secrets Setup

Add these secrets to your GitHub repository:

- `GCP_PROJECT_ID`: Your GCP project ID
- `GCP_SA_KEY`: Contents of the `key.json` file
- `GCP_REGION`: Your preferred GCP region

## Security Considerations

⚠️ **Important**: The service account key is stored in Terraform state. For production use, consider:

1. Using [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) instead of service account keys
2. Storing Terraform state in a secure backend (GCS bucket with encryption)
3. Using separate environments for dev/staging/production

## Alternative: Workload Identity Federation

For enhanced security, consider using Workload Identity Federation instead of service account keys. This eliminates the need to store long-lived credentials.

## Cleanup

To destroy the created resources:

```bash
terraform destroy
```

## Outputs

- `service_account_email`: Email of the created service account
- `service_account_key`: Base64 encoded service account key (sensitive)
- `project_id`: The GCP project ID 
