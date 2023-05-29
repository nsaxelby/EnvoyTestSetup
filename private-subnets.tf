resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_route_table" "priv1-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "priv1-rt"
  }
}

resource "aws_route" "priv1-internet-to-nat" {
  route_table_id         = aws_route_table.priv1-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway-1.id
}

resource "aws_route_table_association" "priv1-rt-assoc" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.priv1-rt.id
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_route_table" "priv2-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "priv2-rt"
  }
}

resource "aws_route" "priv2-internet-to-nat" {
  route_table_id         = aws_route_table.priv2-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway-1.id
}

resource "aws_route_table_association" "priv2-rt-assoc" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.priv2-rt.id
}

resource "aws_subnet" "private-subnet-3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "private-subnet-3"
  }
}

resource "aws_route_table" "priv3-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "priv3-rt"
  }
}

resource "aws_route" "priv3-internet-to-nat" {
  route_table_id         = aws_route_table.priv3-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway-1.id
}

resource "aws_route_table_association" "priv3-rt-assoc" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.priv3-rt.id
}
