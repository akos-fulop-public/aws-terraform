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

resource "aws_key_pair" "akos_personal" {
  key_name   = "akos-notebook"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkLaudn7GAkiW8Z7/GVas6EjCQ2lf+/oFPhRCK5P5aD akos.fulop.github@gmail.com"
}


variable "deploy_ec2_playground" {
  type = bool
  default = false
}

module "ec2_practice_env" {
  source = "./ec2practice"
  count = var.deploy_ec2_playground == true ? 1 : 0
}

output "scaling_web_app_url" {
  value = module.ec2_practice_env[*].app_url
}


variable "deploy_s3_playground" {
  type = bool
  default = false
}

module "s3_practice_env" {
  source = "./s3practice"
  count = var.deploy_s3_playground == true ? 1 : 0
}

output "static_web_app_url" {
  value = module.s3_practice_env[*].app_url
}


variable "deploy_serverless_app" {
  type = bool
  default = false
}

module "serverless_env" {
  source = "./serverless"
  count = var.deploy_serverless_app == true ? 1 : 0
}
