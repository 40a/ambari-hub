######### Creating ACL's #########

resource "cloudstack_network_acl" "management" {
    name = "${var.network_name.management}"
    vpc = "${cloudstack_vpc.main.name}"
}

resource "cloudstack_network_acl_rule" "management" {
  aclid = "${cloudstack_network_acl.management.id}"
  depends_on = "cloudstack_instance.bastion"
  rule {
    action = "allow"
    source_cidr  = "${var.safe_ips.home}" # Home 
    protocol = "all"
    traffic_type = "ingress"
  }

  rule {
    action = "allow"
    source_cidr  = "${var.safe_ips.office}" # Office 
    protocol = "all"
    traffic_type = "ingress"
  }

  rule {
    action = "allow"
    source_cidr  = "0.0.0.0/0" # The Internet 
    protocol = "all"
    traffic_type = "egress"
  }
  rule {
    action = "allow"
    source_cidr  = "${var.network_cidr.analytics}"
    protocol = "all"
    traffic_type = "ingress"
  }
}

resource "cloudstack_network" "management" {
    name = "${var.network_name.management}"
    cidr = "${var.network_cidr.management}"
    network_offering = "${var.network_offering}"
    zone = "${var.vpc_zone}"
    vpc = "${cloudstack_vpc.main.name}"
    aclid = "${cloudstack_network_acl.management.id}"
}

resource "cloudstack_ipaddress" "management" {
    vpc = "${cloudstack_vpc.main.name}"
}

output "management-publicip" {
    value = "${cloudstack_ipaddress.management.ipaddress}"
}