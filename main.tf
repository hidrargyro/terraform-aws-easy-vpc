#"10.0.0.0/16"
resource "aws_vpc" "vpc" {
  for_each                         = var.vpcs
  cidr_block                       = each.value.cidr
  enable_dns_hostnames             = each.value.enable_dns_hostnames
  enable_dns_support               = each.value.enable_dns_support

  tags = {
      "Name" = "${var.environment}-${each.key}"
    }
}

resource "aws_internet_gateway" "igw" {
  for_each = var.vpcs
  vpc_id = aws_vpc.vpc[each.key].id
}

resource "aws_subnet" "subnet" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.vpc[each.value.vpc].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
      "Name" = "${var.environment}-${each.key}"
  }
}

resource "aws_route_table" "routeTable" {
  for_each = var.subnets
  vpc_id   = aws_vpc.vpc[each.value.vpc].id

  tags = {
    Name = "${var.environment}-${each.key}"
  }
}


locals {
  publicSubnets = {
    for key, subnet in var.subnets :
    key => subnet
    if (subnet.public == true)
  }
}

resource "aws_route" "igw" {
  for_each               = local.publicSubnets
  route_table_id         = aws_route_table.routeTable[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[each.value.vpc].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "routeToSubnet" {
  for_each       = var.subnets
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.routeTable[each.key].id
}

resource "aws_network_acl" "acl" {
  for_each = var.vpcs
  vpc_id = aws_vpc.vpc[each.key].id
}

resource "aws_network_acl_rule" "ingress" {
  for_each = var.vpcs
  network_acl_id = aws_network_acl.acl[each.key].id
  rule_number    = 200
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "egress" {
  for_each = var.vpcs
  network_acl_id = aws_network_acl.acl[each.key].id
  rule_number    = 200
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}



resource "aws_security_group" "securityGroup" {
  for_each = var.securityGroups
  name     = "${var.environment}-${each.key}"
  vpc_id   = aws_vpc.vpc[each.value.vpc].id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = ingress.key
      from_port   = ingress.value.fromPort
      to_port     = ingress.value.toPort
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidrBlock
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      description = egress.key
      from_port   = egress.value.fromPort
      to_port     = egress.value.toPort
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidrBlock
    }
  }

  tags = {
    "Name" = "${var.environment}-${each.key}"
  }
}
