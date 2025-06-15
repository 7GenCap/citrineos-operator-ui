#!/bin/bash

# CitrineOS Operator UI - GCP Infrastructure Setup Script
# This script automates the Terraform deployment for GitHub Actions service account

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it from https://www.terraform.io/downloads.html"
        exit 1
    fi
    
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK is not installed. Please install it from https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Check if user is authenticated with gcloud
check_gcloud_auth() {
    print_status "Checking Google Cloud authentication..."
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_warning "You are not authenticated with Google Cloud. Initiating login..."
        
        if ! gcloud auth login; then
            print_error "Authentication failed. Please try again."
            exit 1
        fi
        
        print_success "Google Cloud authentication completed"
    else
        print_success "Google Cloud authentication verified"
    fi
}

# Get project ID from user or gcloud config
get_project_id() {
    if [ -z "$PROJECT_ID" ]; then
        # Try to get from gcloud config
        PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
        
        if [ -z "$PROJECT_ID" ]; then
            echo -n "Enter your GCP Project ID: "
            read PROJECT_ID
        else
            print_status "Using project ID from gcloud config: $PROJECT_ID"
            echo -n "Press Enter to continue or type a different project ID: "
            read USER_PROJECT_ID
            if [ ! -z "$USER_PROJECT_ID" ]; then
                PROJECT_ID=$USER_PROJECT_ID
            fi
        fi
    fi
    
    if [ -z "$PROJECT_ID" ]; then
        print_error "Project ID is required"
        exit 1
    fi
    
    export PROJECT_ID
    print_success "Using project ID: $PROJECT_ID"
}

# Get region from user
get_region() {
    if [ -z "$REGION" ]; then
        echo -n "Enter your preferred GCP region (default: northamerica-northeast1): "
        read REGION
        if [ -z "$REGION" ]; then
            REGION="northamerica-northeast1"
        fi
    fi
    
    export REGION
    print_success "Using region: $REGION"
}

# Create terraform.tfvars file
create_tfvars() {
    print_status "Creating terraform.tfvars file..."
    
    cat > terraform.tfvars << EOF
# Auto-generated terraform.tfvars
project_id = "$PROJECT_ID"
region     = "$REGION"
EOF
    
    print_success "Created terraform.tfvars"
}

# Initialize and apply Terraform
deploy_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    
    print_status "Planning Terraform deployment..."
    terraform plan
    
    echo
    print_warning "This will create the following resources in your GCP project:"
    print_warning "- Service account for GitHub Actions"
    print_warning "- IAM role bindings"
    print_warning "- Service account key"
    print_warning "- Enable required APIs"
    echo
    
    echo -n "Do you want to proceed? (y/N): "
    read CONFIRM
    
    if [[ $CONFIRM =~ ^[Yy]$ ]]; then
        print_status "Applying Terraform configuration..."
        terraform apply -auto-approve
        print_success "Terraform deployment completed!"
    else
        print_warning "Deployment cancelled"
        exit 0
    fi
}

# Extract service account key
extract_key() {
    print_status "Extracting service account key..."
    
    # Get the base64 encoded key
    terraform output -raw service_account_key > key.json.b64
    
    # Decode the key
    if command -v base64 &> /dev/null; then
        base64 -d key.json.b64 > key.json
    else
        # For systems without base64 command
        python3 -c "import base64, sys; sys.stdout.buffer.write(base64.b64decode(sys.stdin.read()))" < key.json.b64 > key.json
    fi
    
    print_success "Service account key saved to key.json"
    print_warning "Remember to add this key to your GitHub repository secrets as GCP_SA_KEY"
}

# Display next steps
show_next_steps() {
    echo
    print_success "🎉 Setup completed successfully!"
    echo
    print_status "Next steps:"
    echo "1. Add the following secrets to your GitHub repository:"
    echo "   - GCP_PROJECT_ID: $PROJECT_ID"
    echo "   - GCP_REGION: $REGION"
    echo "   - GCP_SA_KEY: Contents of the key.json file"
    echo
    echo "2. The service account email is:"
    terraform output service_account_email
    echo
    echo "3. You can now use the GitHub Actions workflow for deployment"
    echo
    print_warning "Security reminder: Store the key.json file securely and delete it after adding to GitHub secrets"
}

# Main execution
main() {
    echo "🚀 CitrineOS Operator UI - GCP Infrastructure Setup"
    echo "=================================================="
    echo
    
    check_prerequisites
    check_gcloud_auth
    get_project_id
    get_region
    create_tfvars
    deploy_terraform
    extract_key
    show_next_steps
}

# Run main function
main "$@" 
