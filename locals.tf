
locals {
  network_firewall_enabled = "false"
  # warning, this takes about 35 minutes if true! 
  kafka_msk_enabled = "true"

  kafka_username = "my-user"
  kafka_password = "supersecrets"
}
