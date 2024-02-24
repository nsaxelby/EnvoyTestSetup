################################################################################
# Client Machine (EC2 instance)
################################################################################
output "execute_this_to_access_the_bastion_host" {
  value = "ssh ec2-user@${aws_instance.bastion-host[0].public_ip} -i cert.pem"
}

output "execute_for_curl" {
  value = "curl http://${aws_lb.my-nlb.dns_name}/json"
}

output "execute_for_kafka_consume" {
  value = "/kafka_2.13-3.4.0/bin/kafka-console-consumer.sh --bootstrap-server ${split(",", data.local_file.foo[0].content)[0]} --consumer.config /config.properties --topic envoy-logs --from-beginning"
}

output "kafka_ui_url" {
  value = "http://${aws_instance.bastion-host[0].public_ip}:8080"
}
