terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  default_tags {
    tags = {
      terraform = "true"
      project = "MLOps CEIA"
  }
  }
}