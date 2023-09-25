variable "region" {
  default = "eu-central-1"
}

variable "profile" {
  default = "terraform"
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
  count = 1
}
