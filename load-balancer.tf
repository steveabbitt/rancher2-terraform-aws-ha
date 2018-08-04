# Application load balancer

resource "aws_lb" "rancher" {
  name                       = "${var.rancher_name}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.alb.id}"]
  ip_address_type            = "ipv4"
  enable_deletion_protection = "false"
  subnets                    = ["${aws_subnet.rancher-master-01.id}", "${aws_subnet.rancher-master-02.id}", "${aws_subnet.rancher-master-03.id}"]
}

# Target group

resource "aws_lb_target_group" "http" {
  name        = "${var.rancher_name}-http-80"
  vpc_id      = "${aws_vpc.rancher-master.id}"
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"

  health_check {
    path = "/healthz"
  }
}

resource "aws_lb_target_group_attachment" "01" {
  target_group_arn = "${aws_lb_target_group.http.arn}"
  target_id        = "${aws_instance.01.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "02" {
  target_group_arn = "${aws_lb_target_group.http.arn}"
  target_id        = "${aws_instance.02.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "03" {
  target_group_arn = "${aws_lb_target_group.http.arn}"
  target_id        = "${aws_instance.03.id}"
  port             = 80
}

# Configure listeners

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.rancher.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.rancher.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.ssl_cert_arn}"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}

# Security group

resource "aws_security_group" "alb" {
  name        = "${var.rancher_name}-alb"
  description = "Rancher App Load Balancer"
  vpc_id      = "${aws_vpc.rancher-master.id}"

  tags {
    Name = "${var.rancher_name}-alb"
  }

  ingress {
    description = "http"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
