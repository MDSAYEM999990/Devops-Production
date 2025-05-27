resource "aws_subnet" "private_subnet_a" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_a_cidr
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "vault-private-a"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = { Name = "private-route-table" }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private.id
}

# 🔐 VPC Interface Endpoints for SSM
locals {
  endpoints = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "ec2"
  ]
}

 resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each = toset(local.endpoints)

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet_a.id]
  security_group_ids = [var.security_group_id]

  private_dns_enabled = true

  tags = {
    Name = "vpce-${each.key}"
  }
}
