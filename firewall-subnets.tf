resource "aws_subnet" "fw-subnet-1" {
  count             = local.network_firewall_enabled ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "fw-subnet-1"
  }
}

resource "aws_subnet" "fw-subnet-2" {
  count             = local.network_firewall_enabled ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "fw-subnet-2"
  }
}

resource "aws_subnet" "fw-subnet-3" {
  count             = local.network_firewall_enabled ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.9.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "fw-subnet-3"
  }
}

resource "aws_route_table" "fw-rt" {
  count  = local.network_firewall_enabled ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "fw-rt"
  }
}

resource "aws_route" "fw-route-to-igw" {
  count                  = local.network_firewall_enabled ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.fw-rt[0].id
}

resource "aws_route_table_association" "fw1-rt-assoc" {
  count          = local.network_firewall_enabled ? 1 : 0
  subnet_id      = aws_subnet.fw-subnet-1[0].id
  route_table_id = aws_route_table.fw-rt[0].id
}

resource "aws_route_table_association" "fw2-rt-assoc" {
  count          = local.network_firewall_enabled ? 1 : 0
  subnet_id      = aws_subnet.fw-subnet-2[0].id
  route_table_id = aws_route_table.fw-rt[0].id
}

resource "aws_route_table_association" "fw3-rt-assoc" {
  count          = local.network_firewall_enabled ? 1 : 0
  subnet_id      = aws_subnet.fw-subnet-3[0].id
  route_table_id = aws_route_table.fw-rt[0].id
}
