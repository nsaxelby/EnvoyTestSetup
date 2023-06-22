# EnvoyTestSetup
Terraform for setting up an ECS Fargate Envoy + HTTPBIN (upstream) with a NLB (3x EIPs) and a Network Firewall.

## Running
`terraform apply`
Terraform builds an image and pushes to ECR, so you will need to docker running.


## Validation
Find your network load balancer address, e.g.: `my-nlb-dc2c1186ac4f1bcb.elb.eu-west-1.amazonaws.com`

Curl the URL: `http://your-nlb-dns-name.com/json` and you will get a template JSON response from HTTPBIN.