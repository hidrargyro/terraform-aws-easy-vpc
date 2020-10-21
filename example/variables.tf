variable "region" {
  default = "us-east-1"
}

variable "environment" {
  default = "production"
}

variable "vpcs" {
  description = "vpcs to be created"
  default = {
    production = {
      cidr                 = "10.0.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true
    }
  }
}

variable "subnets" {
  description = "subnets to be created"
  default = {
    app = {
      vpc    = "production"
      cidr   = "10.0.0.0/20"
      public = true
      az     = null
    }
    database = {
      vpc    = "production"
      cidr   = "10.0.32.0/20"
      public = false
      az     = null
    }
  }
}

variable "securityGroups" {
  description = "security groups to be created (with CIDR source)"
  default = {
    appServer = {
      vpc     = "production"
      ingress = {
        http = {
          fromPort  = 80
          toPort    = 80
          protocol  = "tcp"
          cidrBlock = ["0.0.0.0/0"]
        },
        https = {
          fromPort  = 443
          toPort    = 443
          protocol  = "tcp"
          cidrBlock = ["0.0.0.0/0"]
        }
      }
      egress = {
        all = {
          fromPort  = 0
          toPort    = 0
          protocol  = "-1"
          cidrBlock = ["0.0.0.0/0"]
        }
      }
    }
    appSSH = {
      vpc     = "production"
      ingress = {
        ssh = {
          fromPort  = 22
          toPort    = 22
          protocol  = "tcp"
          cidrBlock = ["0.0.0.0/0"]
        }
      }
      egress = {
        all = {
          fromPort  = 0
          toPort    = 0
          protocol  = "-1"
          cidrBlock = ["0.0.0.0/0"]
        }
      }
    }
  }
}