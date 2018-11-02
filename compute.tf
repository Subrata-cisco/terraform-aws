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
  associate_public_ip_address = "true"
  tags {
    Name = "kmsresource"
  }
  subnet_id = "${aws_subnet.kms_public_subnet.id}"
  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y httpd24
  service httpd start
  chkconfig httpd on
  echo "<?php" >> /var/www/html/index.php
  echo "\$conn = new mysqli('${aws_instance.kms_db_compute_machine.private_ip}', 'root', 'secret', 'test');" >> /var/www/html/index.php
  echo "\$sql = 'SELECT * FROM mytable'; " >> /var/www/html/index.php
  echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/index.php
  echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['mycol'] ;} " >> /var/www/html/index.php
  echo "\$conn->close(); " >> /var/www/html/index.php
  echo "?>" >> /var/www/html/index.php
  HEREDOC
}

resource "aws_instance" "kms_db_compute_machine" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  associate_public_ip_address = "false"
  tags {
    Name = "kmsprivateresource"
  }
  subnet_id = "${aws_subnet.kms_private_subnet.id}"
  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y mysql55-server
  service mysqld start
  /usr/bin/mysqladmin -u root password 'secret'
  mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
  mysql -u root -psecret -e 'CREATE TABLE mytable (mycol varchar(255));' test
  mysql -u root -psecret -e "INSERT INTO mytable (mycol) values ('kmsTenant1') ;" test
  HEREDOC
}

resource "aws_elb" "kms_app_facing_loadbalancer" {
  name = "kms-lb"
  internal = "false"
  load_balancer_type = "application"
  subnets = ["${aws_subnet.kms_public_subnet.id}","${aws_subnet.kms_public_subnet2.id}"]
  enable_deletion_protection = true

  access_logs {
    bucket = "subsl"
    enabled = true
  }

  "listener" {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.kms_compute_machine.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}

