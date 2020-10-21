# terraform-aws-easy-vpc
A Terraform module to create an AWS VPC in an easy manner. You provide a list of VPCs to
be created, a list of subnets and a list of security groups and the module takes care of
the creation and assigment of each resource.

## Usage

### Default Configuration
This module does not create any resource by default. You have to provide a list for each resource
you want to create, check the format of each list in the __*var Formats*__ section.

```
module "vpc" {
  source         = "hidrargyro/easy-vpc/aws"
  environment    = "production"
  region         = "eu-west-2"
  vpcs           = var.vpcs
  subnets        = var.subnets
  securityGroups = var.securityGroups
}
```

### var Formats


#### vpcs

* Format:

```
variable "vpcs" {
  description = "vpcs to be created"
  type = map(object({
    cidr                 = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
  }))
}
```

You only need to define a map containing all th vpc you needs to create. The only three parameters
available are `cidr`, `enable_dns_hostnames` and `enable_dns_support`

* Example:

```
variable "vpcs" {
  description = "vpcs to be created"
  default = {
    vpcProduction = {
      cidr                 = "10.0.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true
    }
  }
}
```

#### subnets

* Format:

```
variable "subnets" {
  description = "subnets to be created"
  type = map(object({
    vpc    = string
    cidr   = string
    public = bool
    az     = string
  }))
}
```

You only need to define a map containing all the subnets you needs to create. The parameters
available are:

1. `vpc`    : The name of the vpc to associate the subnet, it must be present in the vpcs list
2. `cidr`   : Must be a valid subrange of the VPC
3. `public` : **true** if you need this vpc routed to internet
4. `az`     : **null** if you want to let aws choose randomly

* Example:

```
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
```

#### securityGroups

* Format:

```
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
```
Define a map containing all the security groups you needs to create. The parameters
available are:

1. `vpc`     : The name of the vpc to associate the security group, it must be present in the vpcs list
2. `ingress` : Map of rules for incoming traffic
3. `egress`  : Map of rules for outgoing traffic

For `ingress` and `egress` parameters, you can configure the following options:

* Options
  * `fromPort`  : Initial port of the range of the allowed ports
  * `toPort`    : Final port of the range of the allowed ports
  * `protocol`  : Protocol of the traffic to allow communication **-1** for all the Protocols
  * `cidrBlock` : Block of IPs allowed


* Example:

```
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
```
