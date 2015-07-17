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
    ttl        = "1"
    records    = ["${aws_instance.ambari-master.private_ip}"]
    depends_on = "aws_instance.ambari-master"
}

resource "aws_route53_record" "ambari_masters_public" {
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "1"
    records    = ["${aws_instance.ambari-master.public_ip}"]
}

resource "aws_route53_record" "ambari_agent_private" {
    count      = "${var.ambari-agents}"
    zone_id    = "${aws_route53_zone.private_horizon.zone_id}"
    name       = "${var.hostname.agents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "1"
    records    = ["${element(aws_instance.ambari-agent.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "ambari_agent_public" {
    count      = "${var.ambari-agents}"
    zone_id    = "${var.route53_public_horizon.zone_id}"
    name       = "${var.hostname.agents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone}"
    type       = "A"
    ttl        = "1"
    records    = ["${element(aws_instance.ambari-agent.*.public_ip, count.index)}"]
}