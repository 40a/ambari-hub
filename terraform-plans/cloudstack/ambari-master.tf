resource "cloudstack_instance" "ambari-master" {
    name              = "${var.instance_name.ambari-master}"
    service_offering  = "${var.instance_type.ambari-master}"
    network           = "${cloudstack_network.ambari.name}"
    template          = "${var.instance_template.ambari-master}"
    zone              = "${var.vpc_zone}"
    expunge           = true
    depends_on        = "cloudstack_instance.bastion"
}

resource "cloudstack_port_forward" "ambari-master" {
    ipaddress = "${cloudstack_ipaddress.ambari.ipaddress}"

    forward {
        protocol = "tcp"
        private_port = 22
        public_port = 22
        virtual_machine = "${cloudstack_instance.ambari-master.id}"
    }

    forward {
        protocol = "tcp"
        private_port = 8080
        public_port = 8080
        virtual_machine = "${cloudstack_instance.ambari-master.id}"
    }
    depends_on = ["cloudstack_instance.ambari-master"]

    connection {
      type              = "ssh"
      host              = "${cloudstack_instance.ambari-master.ipaddress}"
      user              = "${var.username}"
      key_file          = "${var.private_key}"
      bastion_host      = "${cloudstack_ipaddress.management.ipaddress}"
    }
    provisioner "file" {
      source = "../../scripts/terraform/bootstrap_server.sh"
      destination = "bootstrap_server.sh"
    }

    provisioner "file" {
      source = "../../scripts/terraform/bootstrap_agent.sh"
      destination = "bootstrap_agent.sh"
    }

    provisioner "file" {
      source = "../../scripts/terraform/agent-hostname-detector.sh"
      destination = "agent-hostname-detector.sh"
    }

    provisioner "file" {
      source = "../../files/terraform/ambari-agent.ini"
      destination = "ambari-agent.ini"
    }
}