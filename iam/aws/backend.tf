terraform {
  backend "s3" {
    bucket         = "random-company-io-terraform-state"
    key            = "iam/aws/terraform.tfstate"
    region         = "ap-southeast-3"
    encrypt        = true
    dynamodb_table = "random-company-io-terraform-locks"
  }
} 