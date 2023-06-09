# EnvoyTestSetup
Terraform for setting up an ECS Fargate Envoy + HTTPBIN (upstream) with a NLB (3x EIPs) and a Network Firewall.

## Running
`terraform apply`
Terraform builds an image and pushes to ECR, so you will need to docker running.

Note: Current version (29 Jun 2023) has a setup which uses a Kinesis Analytics notebook, this is for network firewall blocking on excessive rates. This is optional, everything will work ok without it, but the Kinesis Analytics notebook creation is not handled by terraform, it has to be done manually (I do it from the AWS console, from the Kinesis stream page). Commands on what to run for rate limiting are in /notebook-queries.


## Validation
Find your network load balancer address, e.g.: `my-nlb-dc2c1186ac4f1bcb.elb.eu-west-1.amazonaws.com`

Curl the URL: `http://your-nlb-dns-name.com/json` and you will get a template JSON response from HTTPBIN.

