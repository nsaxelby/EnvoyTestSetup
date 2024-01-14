# EnvoyTestSetup
Terraform for setting up an ECS Fargate Envoy + HTTPBIN (upstream) with a NLB (3x EIPs) and a Network Firewall.

## Running
`terraform apply`
Terraform builds an image and pushes to ECR, so you will need to docker running.

If `kafka_msk_enabled` is set it will take around 35 minutes to start up the MSK.

Docker must be running in order to build/deploy this project.

Note: Current version (29 Jun 2023) has a setup which uses a Kinesis Analytics notebook, this is for network firewall blocking on excessive rates. This is optional, everything will work ok without it, but the Kinesis Analytics notebook creation is not handled by terraform, it has to be done manually (I do it from the AWS console, from the Kinesis stream page). Commands on what to run for rate limiting are in /notebook-queries.

## Validation
Find your network load balancer address, e.g.: `my-nlb-dc2c1186ac4f1bcb.elb.eu-west-1.amazonaws.com`

Curl the URL: `http://your-nlb-dns-name.com/json` and you will get a template JSON response from HTTPBIN.

Note, on destroy, the SG and one of the subnets may fail to delete e.g. looping on:
`aws_subnet.private-subnet-2: Still destroying... [id=subnet-02c14dbd437c41787, 3m50s elapsed]
aws_security_group.flinksg: Still destroying... [id=sg-02d2488532da9a0c2, 3m50s elapsed]`

This is a bug. When destroying the managed flink, it appears the provider doesn't clean up the network interfaces used by the flink app. You may need to go into the console and delete the network interfaces manually, Ec2 > Network and Security > network interfaces.