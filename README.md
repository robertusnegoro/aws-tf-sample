# AWS-GCP Migration Infrastructure

This repository contains Terraform configurations for AWS and GCP infrastructure required for migration. Each configuration maintains its own state file in its respective cloud storage service.

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. GCP CLI configured with appropriate credentials
3. Terraform installed (version 1.11.0 or later)
4. S3 bucket for AWS Terraform state (in ap-southeast-3 region)
5. Access to GCP project `(staging|prod)-random-gcp-project` for state storage

## Configuration

### AWS Configuration

1. Update `aws/backend.tf` with your S3 bucket details:
   ```hcl
   bucket = "your-aws-terraform-state-bucket"
   region = "ap-southeast-3"
   ```

2. Create `aws/terraform.tfvars.<environment>`:
   ```hcl
   aws_region = "ap-southeast-3"
   aws_vpc_cidr = "10.0.0.0/16"
   aws_direct_connect_location = "your-dx-location"
   aws_direct_connect_connection_name = "your-dx-connection-name"
   aws_transit_gateway_name = "your-tgw-name"
   ```

### GCP Configuration

1. Update `gcp/backend.tf` with your GCS bucket details:
   ```hcl
   bucket = "random-gcp-project"
   prefix = "gcp-migration"
   ```

2. Create `gcp/terraform.tfvars.<environment>`:
   ```hcl
   gcp_project_id = "random-gcp-project"
   gcp_network_name = "your-gcp-network-name"
   gcp_subnet_name = "your-gcp-subnet-name"
   gcp_subnet_cidr = "10.0.0.0/24"
   gcp_cloud_interconnect_name = "your-interconnect-name"
   gcp_cloud_interconnect_location = "your-interconnect-location"
   ```

## Usage

### Manual Deployment

#### Deploying AWS Infrastructure

1. Navigate to the AWS directory:
   ```bash
   cd aws
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. After successful deployment, get the Transit Gateway ID:
   ```bash
   terraform output aws_transit_gateway_id
   ```

#### Deploying GCP Infrastructure

1. Navigate to the GCP directory:
   ```bash
   cd gcp
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. After successful deployment, get the Cloud Interconnect ID:
   ```bash
   terraform output gcp_cloud_interconnect_attachment_id
   ```

### Using Atlantis for Automated Deployment

This project is configured to use Atlantis for automated Terraform operations. The `atlantis.yaml` file defines four main projects:

1. AWS Infrastructure (`aws/`)
2. GCP Infrastructure (`gcp/`)
3. AWS IAM (`iam/aws/`)
4. GCP IAM (`iam/gcp/`)

#### Atlantis Workflow

1. Create a new branch for your changes
2. Make your changes to the Terraform configurations
3. Create a pull request
4. Atlantis will automatically:
   - Run `terraform init` and `terraform plan` on all affected projects
   - Show the plan output in the pull request
   - Wait for approval
   - Run `terraform apply` when approved

#### Atlantis Commands

You can use the following Atlantis commands in pull request comments:

- `atlantis plan` - Run plan on all projects
- `atlantis plan -p aws-infrastructure` - Run plan on AWS infrastructure only
- `atlantis plan -p gcp-infrastructure` - Run plan on GCP infrastructure only
- `atlantis plan -p aws-iam` - Run plan on AWS IAM only
- `atlantis plan -p gcp-iam` - Run plan on GCP IAM only
- `atlantis apply` - Apply all changes (requires approval)
- `atlantis apply -p aws-infrastructure` - Apply AWS infrastructure changes
- `atlantis apply -p gcp-infrastructure` - Apply GCP infrastructure changes
- `atlantis apply -p aws-iam` - Apply AWS IAM changes
- `atlantis apply -p gcp-iam` - Apply GCP IAM changes

#### Atlantis Requirements

- Pull requests must be approved
- Branch must be up to date with base branch
- All plans must pass
- No merge conflicts

## Cross-Reference Configuration

After deploying both infrastructures, you'll need to update the following variables:

1. In `gcp/terraform.tfvars.<environment>`, add:
   ```hcl
   aws_transit_gateway_id = "output-from-aws-transit-gateway-id"
   ```

2. In `aws/terraform.tfvars.<environment>`, add:
   ```hcl
   gcp_cloud_interconnect_attachment_id = "output-from-gcp-cloud-interconnect-id"
   ```

## Important Notes

1. The configuration uses ASN 64512 for both AWS and GCP. Make sure this doesn't conflict with your existing ASN numbers.
2. Make sure the CIDR ranges don't overlap between AWS and GCP networks.
3. The configuration creates subnets in two availability zones by default.
4. All resources are deployed in the Jakarta region:
   - AWS: ap-southeast-3
   - GCP: asia-southeast1

## Cleanup

To destroy the infrastructure:

### AWS Cleanup
```bash
cd aws
terraform destroy
```

### GCP Cleanup
```bash
cd gcp
terraform destroy
```
