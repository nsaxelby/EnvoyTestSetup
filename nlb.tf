resource "aws_lb" "my-nlb" {
  name               = "my-nlb"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = aws_subnet.public-subnet-1.id
    allocation_id = aws_eip.eip1.id
  }

  subnet_mapping {
    subnet_id     = aws_subnet.public-subnet-2.id
    allocation_id = aws_eip.eip2.id
  }

  subnet_mapping {
    subnet_id     = aws_subnet.public-subnet-3.id
    allocation_id = aws_eip.eip3.id
  }
}
