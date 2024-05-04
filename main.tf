data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

resource "random_id" "id" {
  byte_length = 8
}

resource "random_pet" "pet" {
}