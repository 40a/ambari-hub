resource "cloudstack_instance" "bastion" {
    name = "${var.instance_name.bastion}-${count.index}"
    service_offering= "${var.instance_type.bastion}"
    network = "${cloudstack_network.management.name}"
    template = "${var.instance_template.bastion}"
    zone ="${var.vpc_zone}"
    expunge = true
    depends_on = "cloudstack_instance.ambari-master"
}

resource "cloudstack_port_forward" "bastion" {
    ipaddress = "${cloudstack_ipaddress.management.ipaddress}"

    forward {
        protocol = "tcp"
        private_port = 22
        public_port = 443
        virtual_machine = "${cloudstack_instance.bastion.name}"
    }

    forward {
        protocol = "tcp"
        private_port = 80
        public_port = 80
        virtual_machine = "${cloudstack_instance.bastion.name}"
    }
    depends_on = ["cloudstack_instance.bastion"]
}