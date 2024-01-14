resource "aws_msk_cluster" "example" {
  count                  = local.kafka_msk_enabled ? 1 : 0
  cluster_name           = "my-cluster"
  kafka_version          = "3.2.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type = "kafka.t3.small"
    client_subnets = [
      aws_subnet.private-subnet-1.id,
      aws_subnet.private-subnet-2.id,
      aws_subnet.private-subnet-3.id,
    ]
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    security_groups = [aws_security_group.sg-msk[0].id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms[0].arn
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka-cw-logs[0].name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.msk-logs-bucket[0].id
        prefix  = "logs/msk-"
      }
    }
  }

  client_authentication {
    sasl {
      scram = true
    }
  }
}


resource "aws_security_group" "sg-msk" {
  count  = local.kafka_msk_enabled ? 1 : 0
  vpc_id = aws_vpc.main.id
  ingress {
    description     = "From ECS 9094"
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-sg.id]
  }
  ingress {
    description     = "From ECS 9096"
    from_port       = 9096
    to_port         = 9096
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-sg.id]
  }
  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "TCP"
    cidr_blocks = [local.cidr_blocks_bastion_host]
  }
  ingress {
    from_port   = 9094
    to_port     = 9096
    protocol    = "TCP"
    cidr_blocks = [local.cidr_blocks_bastion_host]
  }

  ingress {
    from_port       = 9094
    to_port         = 9096
    protocol        = "TCP"
    security_groups = [aws_security_group.flinksg.id]
  }
}

