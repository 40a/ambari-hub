# Some route53 specifics to make it easier to find web hosts.


# The VPC horizon zone, this will NOT be exposed to public.
resource "aws_route53_zone" "private_horizon" {
  name        = "${var.domain_name.zone}"
  vpc_id      = "${aws_vpc.default.id}"
}

resource "aws_route53_record" "ambari_masters_private" {
    zone_id    = "${aws_route53_zone.private_horizon.zone_id}"
    name       = "${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${aws_instance.ambari_master.private_ip}"]
    depends_on = "aws_instance.ambari_master"
}

resource "aws_route53_record" "ambari_masters_public" {
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${aws_instance.ambari_master.public_ip}"]
}

resource "aws_route53_record" "data_client_private" {
    count      = "${var.counts.data_clients}"
    zone_id    = "${aws_route53_zone.private_horizon.zone_id}"
    name       = "${var.hostname.data_client}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.data_client.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "data_client_public" {
    count      = "${var.counts.data_clients}"
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.data_client}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.data_client.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "compute_client_private" {
    count      = "${var.counts.compute_clients}"
    zone_id    = "${aws_route53_zone.private_horizon.zone_id}"
    name       = "${var.hostname.compute_client}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.compute_client.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "compute_client_public" {
    count      = "${var.counts.compute_clients}"
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.compute_client}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.compute_client.*.public_ip, count.index)}"]
}