resource "cloudstack_instance" "ambari-master" {
    name              = "${var.instance_name.ambari-master}"
    service_offering  = "${var.instance_type.ambari-master}"
    network           = "${cloudstack_network.ambari.name}"
    template          = "${var.instance_template.ambari-master}"
    zone              = "${var.vpc_zone}"
    expunge           = true
#    depends_on        = "cloudstack_instance.bastion"
}

resource "cloudstack_disk" "ambari-master" {
  name             = "ambari-master-data1"
  attach           = "true"
  disk_offering    = "${var.disk_type.large}"
  virtual_machine  = "${cloudstack_instance.ambari-master.id}"
  zone             = "${var.vpc_zone}"
  depends_on       = "cloudstack_instance.bastion"
}

resource "cloudstack_port_forward" "ambari-master" {
    ipaddress  = "${cloudstack_ipaddress.ambari.ipaddress}"
    depends_on = "cloudstack_disk.ambari-master"
    forward {
        protocol = "tcp"
        private_port = 22
        public_port = 22
        virtual_machine = "${cloudstack_instance.ambari-master.name}"
    }

    forward {
        protocol = "tcp"
        private_port = 8080
        public_port = 8080
        virtual_machine = "${cloudstack_instance.ambari-master.name}"
    }
    depends_on = ["cloudstack_instance.ambari-master", "cloudstack_disk.ambari-master"]

    connection {
      type              = "ssh"
      host              = "${cloudstack_instance.ambari-master.ipaddress}"
      user              = "${var.username}"
      agent             = true
      key_file          = "${var.private_key}"
      bastion_host      = "${cloudstack_ipaddress.management.ipaddress}"
      bastion_port      = "443"
    }
    provisioner "file" {
      source = "../../scripts/terraform/cloudstack/bootstrap_server.sh"
      destination = "bootstrap_server.sh"
    }

    provisioner "file" {
      source = "../../scripts/terraform/cloudstack/bootstrap_agent.sh"
      destination = "bootstrap_agent.sh"
    }

    provisioner "file" {
      source = "../../scripts/terraform/cloudstack/agent-hostname-detector.sh"
      destination = "agent-hostname-detector.sh"
    }

    provisioner "file" {
      source = "../../files/terraform/ambari-agent.ini"
      destination = "ambari-agent.ini"
    }
  provisioner "remote-exec" {
      inline = [
      "chmod +x bootstrap_server.sh",
      "chmod +x bootstrap_agent.sh",
      "sudo cp agent-hostname-detector.sh /etc/ambari-agent",
      "sudo chmod +x /etc/ambari-agent/agent-hostname-detector.sh",
      "./bootstrap_server.sh ${var.hostname.ambari-master}.${var.domain_name.zone}",
      "sudo mkdir -p /var/run/ambari-agent/",
      "sudo service firewalld stop",
      "sudo /sbin/chkconfig firewalld off",
      "sudo /sbin/chkconfig ambari-agent on",
      "sudo /sbin/chkconfig ambari-server on",
      "sudo reboot"
      ]
  }
}