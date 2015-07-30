# Creating the analytics network

resource "cloudstack_network_acl" "analytics" {
    name = "${var.network_name.analytics}"
    vpc = "${cloudstack_vpc.main.name}"
}

resource "cloudstack_network_acl_rule" "analytics" {
  aclid = "${cloudstack_network_acl.analytics.id}"
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
    source_cidr  = "0.0.0.0/0"
    protocol = "all"
    traffic_type = "egress"
  }

  rule {
    action = "allow"
    source_cidr  = "${var.network_cidr.management}"  
    protocol = "all"
    traffic_type = "ingress"
  }
}

resource "cloudstack_network" "ambari" {
    name              = "${var.network_name.analytics}"
    cidr              = "${var.network_cidr.analytics}"
    network_offering  = "${var.network_offering}"
    zone              = "${var.vpc_zone}"
    vpc               = "${cloudstack_vpc.main.name}"
    aclid             = "${cloudstack_network_acl.analytics.id}"
//    depends_on        = "cloudstack_instance.bastion"
}

resource "cloudstack_ipaddress" "ambari" {
    vpc = "${cloudstack_vpc.main.name}"
}

output "ambari-publicip" {
    value = "${cloudstack_ipaddress.ambari.ipaddress}"
}