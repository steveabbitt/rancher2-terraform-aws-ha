# rancher2-terraform-aws-ha
Terraform for complete Rancher 2 HA deployment with external load balancer on AWS

## Creates the following resources:
- 3 EC2 Instances with Elastic IPs, Docker 17.03ce, and fail2ban
- Application Load Balancer
- Route 53 DNS Entry
- VPC & Subnets
- Auto-config of Rancher2/Kubernetes Cluster using rke

## Prerequisites:
- Terraform CLI (https://www.terraform.io/intro/getting-started/install.html)
