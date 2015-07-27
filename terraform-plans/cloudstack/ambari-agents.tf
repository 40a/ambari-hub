resource "cloudstack_instance" "ambari-serveragent" {
    count             = "${var.ambari-serveragents}"
    name              = "${var.instance_name.ambari-serveragent}-${count.index}"
    service_offering  = "${var.instance_type.ambari-serveragent}"
    network           = "${cloudstack_network.ambari.name}"
    template          = "${var.instance_template.ambari-serveragent}"
    zone              = "${var.vpc_zone}"
    expunge           = true    
}

resource "cloudstack_instance" "ambari-clientagent" {
    count             = "${var.ambari-clientagents}"
    name              = "${var.instance_name.ambari-clientagent}-${count.index}"
    service_offering  = "${var.instance_type.ambari-clientagent}"
    network           = "${cloudstack_network.ambari.name}"
    template          = "${var.instance_template.ambari-clientagent}"
    zone              = "${var.vpc_zone}"
    expunge           = true    
}