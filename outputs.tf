/*output "kms_end_point" {
  value = "${aws_lb.kms_app_facing_loadbalancer.dns_name}"
}*/

/*output "kms_aws_user_details" {
  value = "${var.aws_access_key} :: ${var.aws_secret_key}"
}*/

output "kms_lb_dns_name" {
  value = "${aws_alb.kms_app_facing_loadbalancer_new.dns_name}"
}

output "kms_bastion_host_ip" {
  value = "${aws_instance.kms_bastion_host_jump_box.public_ip}"
}
