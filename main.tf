variable "region" {
  default = "eu-central-1"
}

variable "profile" {
  default = "terraform"
}

locals {
  deploy_ec2_playground = false
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "akos-fulop"
}

module "ec2_practice_env" {
  source = "./ec2practice"
  count = local.deploy_ec2_playground == true ? 1 : 0
}
