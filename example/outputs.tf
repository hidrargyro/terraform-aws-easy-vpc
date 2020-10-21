output "vpc" {
  value = module.vpc.vpcs
}

output "subnets" {
  value = module.vpc.subnets
}

output "securityGroups"{
  value = module.vpc.securityGroups
}

output "region" {
  value = var.region
}