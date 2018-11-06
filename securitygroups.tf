resource "aws_security_group" "kms_app_server_sg" {
  name   = "appserversg"
  vpc_id = "${aws_vpc.kms_main_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kms_db_server_sg" {
  name   = "dbserversg"
  vpc_id = "${aws_vpc.kms_main_vpc.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = ["${aws_security_group.kms_app_server_sg.id}"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.kms_main_vpc.default_network_acl_id}"
  #vpc_id     = "${aws_vpc.kms_main_vpc.id}"
  #subnet_ids = ["${aws_subnet.kms_public_subnet.id}", "${aws_subnet.kms_public_subnet2.id}", "${aws_subnet.kms_private_subnet.id}"]

  # allow port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.fromAnySourceCIDR}"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "${var.fromAnySourceCIDR}"
    from_port  = 23
    to_port    = 23
  }

  # allow port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "${var.fromAnySourceCIDR}"
    from_port  = 80
    to_port    = 80
  }

  # allow ingress ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "${var.fromAnySourceCIDR}"
    from_port  = 443
    to_port    = 443
  }

  # allow ingress ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "${var.fromAnySourceCIDR}"
    from_port  = 1024
    to_port    = 65535
  }

  # allow egress ephemeral ports
  egress = {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.fromAnySourceCIDR}"
    from_port  = 0
    to_port    = 0
  }
}
