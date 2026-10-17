terraform {
  backend "s3" {
    bucket       = "kafka-one-click-tfstate-506192652789"
    key          = "kafka-one-click-infra/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
