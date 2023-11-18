resource "aws_eip" "eip1" {
  domain = "vpc"
}

resource "aws_eip" "eip2" {
  domain = "vpc"
}

resource "aws_eip" "eip3" {
  domain = "vpc"
}

resource "aws_eip" "eip-nat1" {
  domain = "vpc"
}

# I cannot create enough EIPS for 1:1 nat gateways
# resource "aws_eip" "eip-nat2" {
#   vpc = true
# }

# resource "aws_eip" "eip-nat3" {
#   vpc = true
# }
