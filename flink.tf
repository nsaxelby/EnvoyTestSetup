resource "aws_s3_bucket" "flink-application-bucket" {
  bucket = "flink-app-ns-envoytester"
}

resource "aws_s3_object" "envoy-test-flink-app-jar-file" {
  bucket     = aws_s3_bucket.flink-application-bucket.id
  key        = "envoy-test-flink-application-${local.buildtime}"
  source     = "FlinkStreamingApp/target/${local.buildtime}.jar"
  depends_on = [null_resource.build-flink-jar]
}

resource "null_resource" "delete-flink-jar" {
  provisioner "local-exec" {
    command = <<EOF
    rm FlinkStreamingApp/target/${local.buildtime}.jar
    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_s3_object.envoy-test-flink-app-jar-file,
  ]
}

resource "aws_iam_role" "flink-ser" {
  name = "flink-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "flink-policy" {
  name   = "test_policy"
  role   = aws_iam_role.flink-ser.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadCode",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Sid": "ListCloudwatchLogGroups",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "ListCloudwatchLogStreams",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "PutCloudwatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VPCReadOnlyPermissions",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeDhcpOptions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ENIReadWritePermissions",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_security_group" "flinksg" {
  name        = "flink-sg"
  description = "SG associated with flink job"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_kinesisanalyticsv2_application" "envoy-test-flink" {
  name                   = "envoy-test-flink-application"
  runtime_environment    = "FLINK-1_15"
  service_execution_role = aws_iam_role.flink-ser.arn

  start_application = true

  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.flink-application-bucket.arn
          file_key   = aws_s3_object.envoy-test-flink-app-jar-file.key
        }
      }

      code_content_type = "ZIPFILE"
    }

    vpc_configuration {
      security_group_ids = [aws_security_group.flinksg.id]
      subnet_ids         = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3.id]
    }

    environment_properties {
      property_group {
        property_group_id = "KafkaSource"

        property_map = {
          "bootstrap.servers" = data.local_file.foo[0].content
          "topic"             = "envoy-logs"
        }
      }

      property_group {
        property_group_id = "KafkaSink"

        property_map = {
          "bootstrap.servers" = data.local_file.foo[0].content
          "topic"             = "envoy-logs-output"
        }
      }
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type = "DEFAULT"
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = "DEBUG"
        metrics_level      = "TASK"
      }

      parallelism_configuration {
        auto_scaling_enabled = true
        configuration_type   = "CUSTOM"
        parallelism          = 1
        parallelism_per_kpu  = 1
      }
    }

    application_snapshot_configuration {
      snapshots_enabled = false
    }
  }

  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.flink-cw-ls.arn
  }

  tags = {
    Environment = "test"
  }
}


resource "aws_cloudwatch_log_group" "flink-cw-lg" {
  name = "flink-application-group"
}

resource "aws_cloudwatch_log_stream" "flink-cw-ls" {
  name           = "flink-application-stream"
  log_group_name = aws_cloudwatch_log_group.flink-cw-lg.name
}
