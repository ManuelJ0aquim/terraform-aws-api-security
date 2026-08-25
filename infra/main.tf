terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_instance" "test_cost_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "APISecurityWAF"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Service     = "api-security-services"
    }
  }
}