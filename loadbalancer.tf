resource "aws_alb" "kms_app_facing_loadbalancer_new" {
  name            = "kms-front-end-alb"
  internal        = false
  subnets         = ["${aws_subnet.kms_public_subnet.id}", "${aws_subnet.kms_private_subnet.id}"]
  security_groups = ["${aws_security_group.kms_app_server_sg.id}"]
}

resource "aws_alb_target_group" "kms_compute_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.kms_main_vpc.id}"

  health_check {
    path                = "/index.html"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    matcher             = "200-308"
  }
}

resource "aws_alb_target_group_attachment" "kms_compute_tg_http_attchment" {
  target_group_arn = "${aws_alb_target_group.kms_compute_tg.arn}"
  target_id        = "${aws_instance.kms_compute_machine.id}"
  port             = 80
}

resource "aws_alb_listener" "kms_front_http" {
  load_balancer_arn = "${aws_alb.kms_app_facing_loadbalancer_new.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.kms_compute_tg.arn}"
    type             = "forward"
  }
}
