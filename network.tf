resource "aws_vpc" "kms_main_vpc" {
  cidr_block           = "${var.cidrblock}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "kms_private_subnet" {
  cidr_block        = "${var.cidrblocksn1}"
  vpc_id            = "${aws_vpc.kms_main_vpc.id}"
  availability_zone = "${var.az["az1"]}"
}

resource "aws_subnet" "kms_public_subnet" {
  cidr_block        = "${var.cidrblocksn2}"
  vpc_id            = "${aws_vpc.kms_main_vpc.id}"
  availability_zone = "${var.az["az2"]}"
}
