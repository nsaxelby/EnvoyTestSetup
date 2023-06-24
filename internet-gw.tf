resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "igw-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-rt"
  }
}

resource "aws_route" "igw-fw-to-pub1" {
  count                  = local.network_firewall_enabled ? 1 : 0
  destination_cidr_block = aws_subnet.public-subnet-1.cidr_block
  route_table_id         = aws_route_table.igw-rt.id
  vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.nwfw[0].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.fw-subnet-1[0].id], 0)
}

resource "aws_route" "igw-fw-to-pub2" {
  count                  = local.network_firewall_enabled ? 1 : 0
  destination_cidr_block = aws_subnet.public-subnet-2.cidr_block
  route_table_id         = aws_route_table.igw-rt.id
  vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.nwfw[0].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.fw-subnet-2[0].id], 0)
}

resource "aws_route" "igw-fw-to-pub3" {
  count                  = local.network_firewall_enabled ? 1 : 0
  destination_cidr_block = aws_subnet.public-subnet-3.cidr_block
  route_table_id         = aws_route_table.igw-rt.id
  vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.nwfw[0].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.fw-subnet-3[0].id], 0)
}

resource "aws_route_table_association" "igw-rt-assoc" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.igw-rt.id
}
