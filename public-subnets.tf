

resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_route_table" "pub1-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "pub1-rt"
  }
}

resource "aws_route" "pub1-route-to-fw" {
  count                  = local.network_firewall_enabled ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.nwfw[0].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.fw-subnet-1[0].id], 0)
  route_table_id         = aws_route_table.pub1-rt.id
}

resource "aws_route" "pub1-route-to-internet" {
  count                  = local.network_firewall_enabled ? 0 : 1
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.pub1-rt.id
}

resource "aws_route_table_association" "pub1-rt-assoc" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.pub1-rt.id
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_route_table" "pub2-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "pub2-rt"
  }
}

resource "aws_route" "pub2-route-to-fw" {
  count                  = local.network_firewall_enabled ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.nwfw[0].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.fw-subnet-2[0].id], 0)
  route_table_id         = aws_route_table.pub2-rt.id
}

resource "aws_route" "pub2-route-to-internet" {
  count                  = local.network_firewall_enabled ? 0 : 1
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.pub2-rt.id
}

resource "aws_route_table_association" "pub2-rt-assoc" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.pub2-rt.id
}

resource "aws_subnet" "public-subnet-3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "public-subnet-3"
  }
}

resource "aws_route_table" "pub3-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "pub3-rt"
  }
}

resource "aws_route" "pub3-route-to-fw" {
  count                  = local.network_firewall_enabled ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.nwfw[0].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.fw-subnet-3[0].id], 0)
  route_table_id         = aws_route_table.pub3-rt.id
}

resource "aws_route" "pub3-route-to-internet" {
  count                  = local.network_firewall_enabled ? 0 : 1
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.pub3-rt.id
}

resource "aws_route_table_association" "pub3-rt-assoc" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.pub3-rt.id
}


resource "aws_subnet" "bastion-host-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.cidr_blocks_bastion_host
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "bastion-host-subnet"
  }
}

resource "aws_route_table" "pubbst-rt" {
  count  = local.kafka_msk_enabled ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "pubbst-rt"
  }
}

resource "aws_route" "pubbst-route-to-fw" {
  count                  = local.kafka_msk_enabled ? local.network_firewall_enabled ? 1 : 0 : 0
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.nwfw[0].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.fw-subnet-3[0].id], 0)
  route_table_id         = aws_route_table.pubbst-rt[0].id
}

resource "aws_route" "pubbst-route-to-internet" {
  count                  = local.kafka_msk_enabled ? local.network_firewall_enabled ? 0 : 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.pubbst-rt[0].id
}

resource "aws_route_table_association" "pubbst-rt-assoc" {
  count = local.kafka_msk_enabled ? 1 : 0

  subnet_id      = aws_subnet.bastion-host-subnet.id
  route_table_id = aws_route_table.pubbst-rt[0].id
}
