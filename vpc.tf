# VPC
resource "aws_vpc" "rancher-master" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    Name = "${var.rancher_name}"
  }
}

# Subnets
resource "aws_subnet" "rancher-master-01" {
  vpc_id            = "${aws_vpc.rancher-master.id}"
  cidr_block        = "192.168.0.0/24"
  availability_zone = "${var.zone_01}"

  tags {
    Name = "${var.rancher_name}-01"
  }
}

resource "aws_subnet" "rancher-master-02" {
  vpc_id            = "${aws_vpc.rancher-master.id}"
  cidr_block        = "192.168.1.0/24"
  availability_zone = "${var.zone_02}"

  tags {
    Name = "${var.rancher_name}-02"
  }
}

resource "aws_subnet" "rancher-master-03" {
  vpc_id            = "${aws_vpc.rancher-master.id}"
  cidr_block        = "192.168.2.0/24"
  availability_zone = "${var.zone_03}"

  tags {
    Name = "${var.rancher_name}-03"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "rancher-master" {
  vpc_id = "${aws_vpc.rancher-master.id}"

  tags {
    Name = "${var.rancher_name}"
  }
}

# Routing

resource "aws_route" "interwebs" {
  route_table_id         = "${aws_vpc.rancher-master.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.rancher-master.id}"
}

resource "aws_route_table_association" "01" {
  subnet_id      = "${aws_subnet.rancher-master-01.id}"
  route_table_id = "${aws_vpc.rancher-master.default_route_table_id}"
}

resource "aws_route_table_association" "02" {
  subnet_id      = "${aws_subnet.rancher-master-02.id}"
  route_table_id = "${aws_vpc.rancher-master.default_route_table_id}"
}

resource "aws_route_table_association" "03" {
  subnet_id      = "${aws_subnet.rancher-master-03.id}"
  route_table_id = "${aws_vpc.rancher-master.default_route_table_id}"
}
