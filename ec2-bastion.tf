data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "private_key" {
  count     = local.kafka_msk_enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "private_key" {
  count      = local.kafka_msk_enabled ? 1 : 0
  key_name   = "my-key-bst"
  public_key = tls_private_key.private_key[0].public_key_openssh
}

resource "local_file" "private_key" {
  count    = local.kafka_msk_enabled ? 1 : 0
  content  = tls_private_key.private_key[0].private_key_pem
  filename = "cert.pem"
}

resource "null_resource" "private_key_permissions" {
  count      = local.kafka_msk_enabled ? 1 : 0
  depends_on = [local_file.private_key]
  provisioner "local-exec" {
    command     = "chmod 600 cert.pem"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}

resource "aws_security_group" "bastion-host" {
  count  = local.kafka_msk_enabled ? 1 : 0
  name   = "secgrp-bastion-host"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Stupid work around for querying brokers
resource "null_resource" "getting-brokers" {
  count = local.kafka_msk_enabled ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
    rm -f brokers.txt
    aws kafka get-bootstrap-brokers --cluster-arn ${aws_msk_cluster.example[0].arn} --region=eu-west-1 | jq -r '.BootstrapBrokerStringSaslScram' >> brokers.txt
    EOF
  }
  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_lifecycle_policy.default-policy-otel-repo,
    aws_msk_cluster.example,
  ]
}

data "local_file" "foo" {
  count      = local.kafka_msk_enabled ? 1 : 0
  filename   = "${path.module}/brokers.txt"
  depends_on = [null_resource.getting-brokers[0]]
}

resource "aws_instance" "bastion-host" {
  count                       = local.kafka_msk_enabled ? 1 : 0
  depends_on                  = [aws_msk_cluster.example]
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.private_key[0].key_name
  subnet_id                   = aws_subnet.bastion-host-subnet.id
  vpc_security_group_ids      = [aws_security_group.bastion-host[0].id]
  user_data_replace_on_change = true
  user_data = templatefile("bastion.tftpl", {
    bootstrap_server_1 = split(",", data.local_file.foo[0].content)[0]
    bootstrap_server_2 = split(",", data.local_file.foo[0].content)[1]
    bootstrap_server_3 = split(",", data.local_file.foo[0].content)[2]
    kafka_username     = local.kafka_username
    kafka_password     = local.kafka_password
  })
  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }
  tags = {
    Name = "bastion-host"
  }
}
