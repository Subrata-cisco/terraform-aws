resource "aws_vpc" "kms_main_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "kms_private_subnet" {
  cidr_block        = "${var.cidr_private}"
  vpc_id            = "${aws_vpc.kms_main_vpc.id}"
  availability_zone = "${var.az["az1"]}"
}

resource "aws_subnet" "kms_public_subnet" {
  cidr_block              = "${var.cidr_two}"
  vpc_id                  = "${aws_vpc.kms_main_vpc.id}"
  availability_zone       = "${var.az["az2"]}"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "kms_public_subnet2" {
  cidr_block              = "${var.cidr_three}"
  vpc_id                  = "${aws_vpc.kms_main_vpc.id}"
  availability_zone       = "${var.az["az2"]}"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "kms_internet_gateway" {
  vpc_id = "${aws_vpc.kms_main_vpc.id}"
}

resource "aws_route_table" "kms_public_route_table" {
  vpc_id = "${aws_vpc.kms_main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kms_internet_gateway.id}"
  }
}

resource "aws_route_table_association" "kms_rt_association" {
  route_table_id = "${aws_route_table.kms_public_route_table.id}"
  subnet_id      = "${aws_subnet.kms_public_subnet.id}"
}

resource "aws_eip" "kms_nat_gateway_elastic_ip" {
  vpc = true
}

resource "aws_nat_gateway" "kms_nat_gateway" {
  allocation_id = "${aws_eip.kms_nat_gateway_elastic_ip.id}"
  subnet_id     = "${aws_subnet.kms_public_subnet.id}"
  depends_on    = ["aws_internet_gateway.kms_internet_gateway"]
}

resource "aws_route_table" "kms_private_route_table" {
  vpc_id = "${aws_vpc.kms_main_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.kms_nat_gateway.id}"
  }
}

resource "aws_route_table_association" "kms_private_subnet_route_association" {
  route_table_id = "${aws_route_table.kms_private_route_table.id}"
  subnet_id      = "${aws_subnet.kms_private_subnet.id}"
}
