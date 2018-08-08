### this readme is a work in progress!

# rancher2-terraform-aws-ha
Terraform for complete Rancher 2 HA deployment with external load balancer on AWS

## Basic Instructions

 - Clone repo
 - Run ```terraform init```
 - Copy the ```terraform.tfvars.template``` file to ```terraform.tfvars```
 - Enter values for all fields in ```terraform.tfvars```. If you're not using Route53 for your DNS, leave the value blank and delete/rename the extension of the ```route53.tf``` file.
 - Run ```terraform plan``` to make sure everything's kosher.
 - Run ```terraform apply``` to deploy. This may take around 10 minutes to complete.
 - Browse to the URL you chose and perform initial config of password and URL. If you skipped the Route53 config, you'll need to point your chosen URL to the load balancr CNAME in your DNS registry.
 - Start reading the Rancher docs for next steps. :)
 
## Creates the following resources:
- 3 EC2 Instances with Elastic IPs, Docker 17.03ce, and fail2ban
- Application Load Balancer
- Route 53 DNS Entry
- VPC & Subnets
- Auto-config of Rancher2/Kubernetes Cluster using rke

## Prerequisites:
- Terraform CLI (https://www.terraform.io/intro/getting-started/install.html)
