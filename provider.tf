terraform {
  # state file
  backend "s3" {
    bucket  = "my-terraform-remote-state"
    key     = "terraform/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = "my-profile"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "my-profile"
}