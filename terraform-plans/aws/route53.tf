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
    records    = ["${aws_instance.ambari-master.private_ip}"]
    depends_on = "aws_instance.ambari-master"
}

resource "aws_route53_record" "ambari_masters_public" {
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${aws_instance.ambari-master.public_ip}"]
}

resource "aws_route53_record" "ambari_serveragent_private" {
    count      = "${var.ambari-serveragents}"
    zone_id    = "${aws_route53_zone.private_horizon.zone_id}"
    name       = "${var.hostname.serveragents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.ambari-agents-server.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "ambari_serveragent_public" {
    count      = "${var.ambari-serveragents}"
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.serveragents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.ambari-agents-server.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "ambari_clientagent_private" {
    count      = "${var.ambari-clientagents}"
    zone_id    = "${aws_route53_zone.private_horizon.zone_id}"
    name       = "${var.hostname.clientagents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.ambari-agents-client.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "ambari_clientagent_public" {
    count      = "${var.ambari-clientagents}"
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.clientagents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "60"
    records    = ["${element(aws_instance.ambari-agents-client.*.public_ip, count.index)}"]
}