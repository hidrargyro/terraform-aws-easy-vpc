variable "environment" {
  description = "name of the deployment"
}

variable "region" {
  description = "region of the deployment"
}

variable "vpcs" {
  description = "vpcs to be created"
  type = map(object({
    cidr                 = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
  }))
}

variable "subnets" {
  description = "subnets to be created"
  type = map(object({
    vpc    = string
    cidr   = string
    public = bool
    az     = string
  }))
}

variable "securityGroups" {
  description = "security groups to be created (with CIDR source)"
  type = map(object({
    vpc = string
    ingress = map(object({
      fromPort  = string
      toPort    = string
      protocol  = string
      cidrBlock = list(string)
    }))
    egress = map(object({
      fromPort  = string
      toPort    = string
      protocol  = string
      cidrBlock = list(string)
    }))
  }))
}