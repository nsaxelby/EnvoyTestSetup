resource "aws_networkfirewall_firewall" "nwfw" {
  name                = "my-network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.myfwpolicy.arn
  vpc_id              = aws_vpc.main.id
  subnet_mapping {
    subnet_id = aws_subnet.fw-subnet-1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.fw-subnet-2.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.fw-subnet-3.id
  }
}

resource "aws_networkfirewall_rule_group" "my-stateful-rule-group" {
  capacity = 100
  name     = "my-rule-group"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      stateful_rule {
        action = "ALERT"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "IP"
          source           = "109.157.102.239"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["11"]
        }

        rule_option {
          keyword  = "msg"
          settings = ["\"DROP ALL MY HOME IP\""]
        }
      }

      stateful_rule {
        action = "ALERT"
        header {
          destination      = "ANY"
          destination_port = "80"
          direction        = "ANY"
          protocol         = "IP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["22"]
        }

        rule_option {
          keyword  = "msg"
          settings = ["\"Alert on 80\""]
        }
      }
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }
}

resource "aws_networkfirewall_rule_group" "my-stateless-rule-group" {
  description = "Forward all to stateful"
  capacity    = 5
  name        = "my-stateless-rule-group"
  type        = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              protocols = [6]
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "myfwpolicy" {
  name = "my-fw-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]
    # stateful_rule_group_reference {
    #   priority     = 2
    #   resource_arn = aws_networkfirewall_rule_group.my-stateful-rule-group.arn
    # }

    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.my-stateless-rule-group.arn
    }
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

resource "aws_networkfirewall_logging_configuration" "cloudwatch-logging-config-nwfw" {
  firewall_arn = aws_networkfirewall_firewall.nwfw.arn
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
