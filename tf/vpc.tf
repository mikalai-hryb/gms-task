###############################################################################
# VPC and Subnets
###############################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.private_subnet_cidrs, each.key))
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.base_name}-private-${element(data.aws_availability_zones.available.names, index(var.private_subnet_cidrs, each.key))}"
    Type = "private"
  }
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.public_subnet_cidrs, each.key))
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.base_name}-public-${element(data.aws_availability_zones.available.names, index(var.public_subnet_cidrs, each.key))}"
    Type = "public"
  }
}

###############################################################################
# Route Tables
###############################################################################
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_default_route_table" "private" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = {
    Name = "${local.base_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_default_route_table.private.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_default_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${local.base_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
