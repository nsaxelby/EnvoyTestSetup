resource "aws_eip" "eip1" {
  vpc = true
}

resource "aws_eip" "eip2" {
  vpc = true
}

resource "aws_eip" "eip3" {
  vpc = true
}

resource "aws_eip" "eip-nat1" {
  vpc = true
}

# I cannot create enough EIPS for 1:1 nat gateways
# resource "aws_eip" "eip-nat2" {
#   vpc = true
# }

# resource "aws_eip" "eip-nat3" {
#   vpc = true
# }
