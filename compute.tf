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
  #ami                         = "${data.aws_ami.ubuntu.id}"
  ami                         = "ami-061e7ebbc234015fe" #Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  key_name                    = "kms-key-pair"

  tags {
    Name = "kmsresource"
  }

  subnet_id       = "${aws_subnet.kms_public_subnet.id}"
  security_groups = ["${aws_security_group.kms_app_server_sg.id}"]

  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y
  sudo yum install httpd -y
  sudo chmod 777 /var/www/html/
  sudo echo "Welcome to subrata's static site.." >> /var/www/html/index.html
  sudo systemctl start httpd && sudo systemctl enable httpd

  #echo "<?php" >> /var/www/html/index.php
  #echo "\$sql = 'SELECT * FROM serviceinstance'; " >> /var/www/html/index.php
  #echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/index.php
  #echo "while(\$row = \$result->fetch_assoc()) { echo 'Service Instance name is :' . \$row['mycol'] ;} " >> /var/www/html/index.php
  #echo "\$conn->close(); " >> /var/www/html/index.php
  #echo "?>" >> /var/www/html/index.php
  HEREDOC
}

/*resource "aws_instance" "kms_db_compute_machine" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id                   = "${aws_subnet.kms_private_subnet.id}"
  security_groups             = ["${aws_security_group.kms_db_server_sg.id}"]

  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y mysql55-server
  service mysqld start
  /usr/bin/mysqladmin -u root password 'secret'
  mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
  mysql -u root -psecret -e 'CREATE TABLE serviceinstance (mycol varchar(255));' test
  mysql -u root -psecret -e "INSERT INTO serviceinstance (mycol) values ('kmsTenant1') ;" test
  HEREDOC
}*/

