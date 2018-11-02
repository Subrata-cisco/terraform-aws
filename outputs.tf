output "kms_end_point" {
  value = "${aws_elb.kms_app_facing_loadbalancer.dns_name}"
}

/*output "kms_aws_user_details" {
  value = "${var.aws_access_key} :: ${var.aws_secret_key}"
}*/

output "kms_instance_ip" {
  value = "${aws_instance.kms_compute_machine.associate_public_ip_address}"
}