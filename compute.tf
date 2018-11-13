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

resource "aws_instance" "kms_bastion_host_jump_box" {
  ami                         = "${var.amazon_linux_ami}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  key_name                    = "kms-key-pair"
  depends_on                  = ["aws_nat_gateway.kms_nat_gateway"]

  tags {
    Name = "kms-bastion-host-jumpbox"
  }

  subnet_id       = "${aws_subnet.kms_public_subnet.id}"
  security_groups = ["${aws_security_group.kms_app_server_sg.id}"]

  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y
  HEREDOC
}

resource "aws_instance" "kms_compute_machine" {
  ami                         = "${var.amazon_linux_ami}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  key_name                    = "kms-key-pair"
  depends_on                  = ["aws_nat_gateway.kms_nat_gateway"]

  tags {
    Name = "kmscompute"
  }

  subnet_id       = "${aws_subnet.kms_private_subnet.id}"
  security_groups = ["${aws_security_group.kms_app_server_sg.id}"]

  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y httpd24 php70 php70-mysqlnd
  sudo service httpd start
  sudo chkconfig httpd on
  sudo chmod 777 /var/www/html/

  echo "<p>Welcome to Oracle Key Management Cloud Service.</p><p><a href='db.php'>See all Service Instance</a></p>" > /var/www/html/index.html
  echo "<?php" >> /var/www/html/db.php
  echo "\$conn = new mysqli('db.kmsdbdns', 'root', 'secret', 'globalkms');" >> /var/www/html/db.php
  echo "\$sql = 'SELECT * FROM serviceinstance'; " >> /var/www/html/db.php
  echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/db.php
  echo "while(\$row = \$result->fetch_assoc()) { echo 'SI Name :' . \$row['siname'] ;} " >> /var/www/html/db.php
  echo "\$conn->close(); " >> /var/www/html/db.php
  echo "?>" >> /var/www/html/db.php
  HEREDOC
}

resource "aws_instance" "kms_db_compute_machine" {
  ami                         = "${var.amazon_linux_ami}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id                   = "${aws_subnet.kms_private_subnet.id}"
  security_groups             = ["${aws_security_group.kms_db_server_sg.id}"]
  key_name                    = "kms-key-pair"
  depends_on                  = ["aws_nat_gateway.kms_nat_gateway"]

  tags {
    Name = "globalkmsdb"
  }

  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y mysql55-server
  sudo service mysqld start
  sudo /usr/bin/mysqladmin -u root password 'secret'
  mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" globalkms
  mysql -u root -psecret -e "GRANT ALL PRIVILEGES ON globalkms.* TO 'root'@'%' identified by 'secret';"
  mysql -u root -psecret -e 'CREATE TABLE serviceinstance (siname varchar(255));' globalkms
  mysql -u root -psecret -e "INSERT INTO serviceinstance (siname) values ('kmsSIForProductionAccountDB') ;" globalkms
  HEREDOC
}
