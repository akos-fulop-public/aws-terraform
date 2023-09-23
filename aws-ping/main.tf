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

provider "aws"{
	region=var.region
	profile=var.profile
}

resource "aws_instance" "app_server" {
	ami           = "ami-01342111f883d5e4e"
	instance_type = "t2.micro"

	tags = {
		Name = "ExampleAppServerInstance"
	}
}
