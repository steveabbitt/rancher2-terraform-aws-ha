# Get AMI of most recent Ubuntu 16.04 image for your region

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

# SSH keys for EC2 access

resource "tls_private_key" "default" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo \"${tls_private_key.default.private_key_pem}\" > ~/.ssh/${var.rancher_name}.pem && chmod 600 ~/.ssh/${var.rancher_name}.pem"
  }
}

resource "aws_key_pair" "default" {
  key_name   = "${var.rancher_name}"
  public_key = "${tls_private_key.default.public_key_openssh}"
}

# Template for user data

data "template_file" "user-data" {
  template = "${file("user_data.tpl")}"
}

# EC2 instances

resource "aws_instance" "01" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.ec2_instance_type}"
  subnet_id              = "${aws_subnet.rancher-master-01.id}"
  vpc_security_group_ids = ["${aws_security_group.ec2.id}", "${aws_vpc.rancher-master.default_security_group_id}"]
  key_name               = "${aws_key_pair.default.key_name}"
  user_data              = "${data.template_file.user-data.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.ebs_volume_size}"
  }

  tags {
    Name = "${var.rancher_name}-01"
  }
}

resource "aws_instance" "02" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.ec2_instance_type}"
  subnet_id              = "${aws_subnet.rancher-master-02.id}"
  vpc_security_group_ids = ["${aws_security_group.ec2.id}", "${aws_vpc.rancher-master.default_security_group_id}"]
  key_name               = "${aws_key_pair.default.key_name}"
  user_data              = "${data.template_file.user-data.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.ebs_volume_size}"
  }

  tags {
    Name = "${var.rancher_name}-02"
  }
}

resource "aws_instance" "03" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.ec2_instance_type}"
  subnet_id              = "${aws_subnet.rancher-master-03.id}"
  vpc_security_group_ids = ["${aws_security_group.ec2.id}", "${aws_vpc.rancher-master.default_security_group_id}"]
  key_name               = "${aws_key_pair.default.key_name}"
  user_data              = "${data.template_file.user-data.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.ebs_volume_size}"
  }

  tags {
    Name = "${var.rancher_name}"
  }
}

# EC2 Security Group

resource "aws_security_group" "ec2" {
  name        = "rancher-ec2"
  description = "Rancher EC2 instances"
  vpc_id      = "${aws_vpc.rancher-master.id}"

  tags {
    Name = "${var.rancher_name}-ec2"
  }

  ingress {
    description = "https"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "skube"
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "http"
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    description = "nodes"
    protocol    = "tcp"
    from_port   = 1
    to_port     = 10250
    cidr_blocks = ["${aws_eip.01.public_ip}/32", "${aws_eip.02.public_ip}/32", "${aws_eip.03.public_ip}/32"]
  }

  egress {
    description = "allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elastic IPs

resource "aws_eip" "01" {
  vpc = true

  tags {
    Name = "${var.rancher_name}-01"
  }

  timeouts {
    read = "1m"
  }
}

resource "aws_eip_association" "01" {
  instance_id        = "${aws_instance.01.id}"
  private_ip_address = "${aws_instance.01.private_ip}"
  allocation_id      = "${aws_eip.01.id}"
  depends_on         = ["aws_instance.01"]
}

resource "aws_eip" "02" {
  vpc = true

  tags {
    Name = "${var.rancher_name}-02"
  }
}

resource "aws_eip_association" "02" {
  instance_id        = "${aws_instance.02.id}"
  private_ip_address = "${aws_instance.02.private_ip}"
  allocation_id      = "${aws_eip.02.id}"
}

resource "aws_eip" "03" {
  vpc = true

  tags {
    Name = "${var.rancher_name}-03"
  }
}

resource "aws_eip_association" "03" {
  instance_id        = "${aws_instance.03.id}"
  private_ip_address = "${aws_instance.03.private_ip}"
  allocation_id      = "${aws_eip.03.id}"
}
