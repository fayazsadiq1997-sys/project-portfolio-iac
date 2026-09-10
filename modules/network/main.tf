locals {
  name_prefix = "${var.project_name}-${var.environment}-"

  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnets = {
    for idx, az in local.azs : az => {
      cidr_block = cidrsubnet(var.cidr_block, 4, idx)
    }
  }

  private_subnets = {
    for idx, az in local.azs : az => {
      cidr_block = cidrsubnet(var.cidr_block, 4, idx + var.az_count)
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${local.name_prefix}vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}gw"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = local.private_subnets
  availability_zone = each.key
  cidr_block        = each.value.cidr_block
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = local.public_subnets
  availability_zone = each.key
  cidr_block        = each.value.cidr_block
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${local.name_prefix}eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[local.azs[0]].id

  tags = {
    Name = "${local.name_prefix}nat"
  }

  # To ensure proper ordering, an explicit dependencyhas been added on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}route-table-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}route-table-private"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
