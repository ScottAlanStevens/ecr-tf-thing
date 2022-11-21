data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  backend "s3" {
    bucket = "scott.artifacts"
    key    = "tfstate-ecr-thing"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
