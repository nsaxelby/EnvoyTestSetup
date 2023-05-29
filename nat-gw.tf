resource "aws_nat_gateway" "nat-gateway-1" {
  subnet_id     = aws_subnet.public-subnet-1.id
  depends_on    = [aws_internet_gateway.igw]
  allocation_id = aws_eip.eip-nat1.id
}

# I cannot create enough EIPS for 1:1 nat gateways
# resource "aws_nat_gateway" "nat-gateway-2" {
#   subnet_id     = aws_subnet.public-subnet-2.id
#   depends_on    = [aws_internet_gateway.igw]
#   allocation_id = aws_eip.eip-nat2.id
# }

# resource "aws_nat_gateway" "nat-gateway-3" {
#   subnet_id     = aws_subnet.public-subnet-3.id
#   depends_on    = [aws_internet_gateway.igw]
#   allocation_id = aws_eip.eip-nat3.id
# }
