resource "aws_networkfirewall_firewall" "nwfw" {
  count               = local.network_firewall_enabled ? 1 : 0
  name                = "my-network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.myfwpolicy[0].arn
  vpc_id              = aws_vpc.main.id
  subnet_mapping {
    subnet_id = aws_subnet.fw-subnet-1[0].id
  }
  subnet_mapping {
    subnet_id = aws_subnet.fw-subnet-2[0].id
  }
  subnet_mapping {
    subnet_id = aws_subnet.fw-subnet-3[0].id
  }
}

resource "aws_networkfirewall_rule_group" "my-stateless-rule-group" {
  count       = local.network_firewall_enabled ? 1 : 0
  description = "Block"
  capacity    = 100
  name        = "my-stateless-rule-group"
  type        = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        custom_action {
          action_definition {
            publish_metric_action {
              dimension {
                value = "2"
              }
            }
          }
          action_name = "ExampleMetricsAction"
        }
        stateless_rule {
          priority = 9
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "myfwpolicy" {
  count = local.network_firewall_enabled ? 1 : 0
  name  = "my-fw-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]

    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.my-stateless-rule-group[0].arn
    }
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

resource "aws_networkfirewall_logging_configuration" "cloudwatch-logging-config-nwfw" {
  count        = local.network_firewall_enabled ? 1 : 0
  firewall_arn = aws_networkfirewall_firewall.nwfw[0].arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network-firewall-log-group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network-firewall-log-group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}
