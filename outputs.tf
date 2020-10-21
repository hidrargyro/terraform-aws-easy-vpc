#locals{
#  vpcIds = {
#    for vpc in keys(var.vpcs):
#    vpc => {
#      "id" = aws_vpc.vpc[vpc].id
#    }
#  }
#
#  vpcs = [
#    for key, data in module.lambda.functions:
#      data.vpc => merge(local.vpcId[data.vpc], {subnets = {arn = data.arn, uri = data.uri}})
#
#}

output "vpcs" {
  value = {
    for vpc in keys(var.vpcs):
    vpc => {
      "id" = aws_vpc.vpc[vpc].id
    }
  }
}

output "subnets" {
  value = {
    for subnet in keys(var.subnets):
    subnet => {
      "id" = aws_subnet.subnet[subnet].id
    }
  }
}

output "securityGroups" {
  value = {
    for securityGroup in keys(var.securityGroups):
    securityGroup => {
      "id" = aws_security_group.securityGroup[securityGroup].id
    }
  }
}