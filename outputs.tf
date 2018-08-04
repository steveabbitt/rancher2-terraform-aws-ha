output "Rancher URL" {
  description = "Your Rancher cluster should now be available at"
  value       = "${var.rancher_url}"
}

output "SSH Key for EC2 Access" {
  description = "Location of SSH key"
  value = "~/.ssh/${var.rancher_name}.pem"
}

output "Main rke files located on EC2 instance" {
  description = "EC2 instance name and IP for rke management"
  value = "${var.rancher_name}-01 (${aws_eip.01.public_ip})"
}
