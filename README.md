# EnvoyTestSetup
Terraform for setting up an ECS Fargate Envoy + HTTPBIN (upstream) with a NLB (3x EIPs) and a Network Firewall.

## Running
`terraform apply`
Terraform builds an image and pushes to ECR, so you will need to docker running.