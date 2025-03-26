terraform {
  backend "s3" {
    bucket         = "random-company-io-terraform-state"
    key            = "aws/terraform.tfstate"
    region         = "ap-southeast-3"
    encrypt        = true
  }
} 