# IAM Configurations for AWS-GCP Migration

This directory contains the IAM configurations for both AWS and GCP, including service accounts for Terraform and user permissions for cloud engineers.

## AWS IAM Configuration

Located in `aws/` directory, this configuration creates:

1. Terraform Service Account:
   - IAM user with access key
   - Policy for EC2, Direct Connect, Transit Gateway, and S3 operations
   - Access key and secret key outputs (sensitive)

2. Cloud Engineers Group:
   - IAM group for cloud engineers
   - User account for cloudengineer@random-company.io
   - Policy for infrastructure management
   - Console access with password (sensitive)

### Usage

1. Navigate to the AWS IAM directory:
   ```bash
   cd aws
   ```

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. Get the service account credentials:
   ```bash
   terraform output terraform_service_account_access_key
   terraform output terraform_service_account_secret_key
   ```

4. Get the cloud engineer password:
   ```bash
   terraform output cloud_engineer_password
   ```

## GCP IAM Configuration

Located in `gcp/` directory, this configuration creates:

1. Terraform Service Account:
   - Service account with key
   - Required IAM roles for infrastructure management
   - Service account email and key outputs (sensitive)

2. Cloud Engineers Group:
   - Cloud Identity group for cloud engineers
   - Required IAM roles for infrastructure management
   - Group email: cloud-engineers@random-company.io

### Usage

1. Navigate to the GCP IAM directory:
   ```bash
   cd gcp
   ```

2. Update `terraform.tfvars` with your GCP customer ID:
   ```hcl
   project_id  = "random-gcp-project"
   customer_id = "your-customer-id"
   ```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Get the service account credentials:
   ```bash
   terraform output terraform_service_account_email
   terraform output terraform_service_account_key
   ```

## Important Notes

1. All sensitive outputs are marked as sensitive in Terraform
2. Store the service account credentials securely
3. The cloud engineer password should be changed on first login
4. Make sure to replace the PGP key in AWS configuration with the actual key
5. Update the GCP customer ID in the tfvars file with your actual ID

## Security Considerations

1. Service account keys should be rotated regularly
2. Use the principle of least privilege when assigning roles
3. Monitor and audit IAM access regularly
4. Consider using AWS SSO or GCP Identity Platform for user management
5. Enable MFA for all user accounts 