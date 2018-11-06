resource "aws_vpc_dhcp_options" "kms_dhcp" {
  domain_name = "${var.dns_name_for_kms_db}"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "kms_dns_resolver" {
  vpc_id = "${aws_vpc.kms_main_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.kms_dhcp.id}"
}

resource "aws_route53_zone" "main" {
  name = "${var.dns_name_for_kms_db}"
  vpc_id = "${aws_vpc.kms_main_vpc.id}"
  comment = "Managed by terraform"
}

resource "aws_route53_record" "kms_database_route_record" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.dns_name_for_kms_db}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.kms_db_compute_machine.private_ip}"]
}