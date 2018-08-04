# Add load balancer URL to Route53

resource "aws_route53_record" "rancher" {
  zone_id  = "${var.route53_zone_id}"
  name     = "${var.rancher_url}"
  type     = "CNAME"
  ttl      = "300"
  records  = ["${aws_lb.rancher.dns_name}"]
}
