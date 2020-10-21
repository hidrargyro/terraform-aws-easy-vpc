provider "aws" {
  region                  = var.region
}

module "vpc" {
  source         = "hidrargyro/easy-vpc/aws"
  environment    = var.environment
  region         = var.region
  vpcs           = var.vpcs
  subnets        = var.subnets
  securityGroups = var.securityGroups
}