data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "kms_compute_machine" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags {
    Name = "kmsresource"
  }

  subnet_id = "${aws_subnet.kms_public_subnet.id}"
}

resource "aws_instance" "kms_db_compute_machine" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags {
    Name = "kmsprivateresource"
  }

  subnet_id = "${aws_subnet.kms_private_subnet.id}"
}
