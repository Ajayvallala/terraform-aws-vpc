resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id = data.aws_vpc.default.id
  vpc_id      = aws_vpc.main.id
  auto_accept = true
 accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = merge(
    local.common_tags,
    var.vpc_peering_tags, {
      Name = "${var.project}-${var.env}"
    }
  )
}


resource "aws_route" "public_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "default_vpc_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}