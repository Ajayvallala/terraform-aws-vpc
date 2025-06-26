resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = merge(
    var.vpc_tags,
    local.common_tags, {
      Name = "${var.project}-${var.env}"
    }
  )
}

resource "aws_ec2_tag" "main_route_table_name" {
  resource_id = data.aws_route_table.main.id
  key         = "Name"
  value       = "${var.project}-${var.env}-main-rt"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags, {
      Name = "${var.project}-${var.env}"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.public_subnet_tags,
    local.common_tags, {
      Name = "${var.project}-${var.env}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.private_subnet_tags,
    local.common_tags, {
      Name = "${var.project}-${var.env}-private-${local.az_names[count.index]}"
    }
  )
}


resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.database_subnet_tags,
    local.common_tags, {
      Name = "${var.project}-${var.env}-database-${local.az_names[count.index]}"
    }
  )
}

resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = merge(
    local.common_tags,
    var.eip_tags, {
      Name = "${var.project}-${var.env}"
    }
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    var.nat_tags, {
      Name = "${var.project}-${var.env}"
    }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.public_route_tags, {
      Name = "${var.project}-${var.env}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.private_route_tags, {
      Name = "${var.project}-${var.env}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.database_route_tags, {
      Name = "${var.project}-${var.env}-database"
    }
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}