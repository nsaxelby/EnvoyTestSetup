################################################################################
# Client Machine (EC2 instance)
################################################################################
output "execute_this_to_access_the_bastion_host" {
  value = "ssh ec2-user@${aws_instance.bastion-host[0].public_ip} -i cert.pem"
}


output "execute_for_curl" {
  value = "curl http://${aws_lb.my-nlb.dns_name}/json"
}
