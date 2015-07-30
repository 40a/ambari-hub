resource "cloudstack_instance" "ambari-serveragent" {
    count             = "${var.ambari-serveragents}"
    name              = "${var.instance_name.ambari-serveragent}-${count.index}"
    service_offering  = "${var.instance_type.ambari-serveragent}"
    network           = "${cloudstack_network.ambari.name}"
    template          = "${var.instance_template.ambari-serveragent}"
    zone              = "${var.vpc_zone}"
    expunge           = true
    depends_on        = ["cloudstack_instance.bastion"]

    connection {
      type              = "ssh"
      host              = "${self.ipaddress}"
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
      "./bootstrap_agent.sh ${var.hostname.ambari-master}.${var.domain_name.zone}",
      "sudo mkdir -p /var/run/ambari-agent/",
      "sudo service firewalld stop",
      "sudo /sbin/chkconfig firewalld off",
      "sudo /sbin/chkconfig ambari-agent on",
      "sudo reboot"
      ]
  }
}

resource "cloudstack_instance" "ambari-clientagent" {
    count             = "${var.ambari-clientagents}"
    name              = "${var.instance_name.ambari-clientagent}-${count.index}"
    service_offering  = "${var.instance_type.ambari-clientagent}"
    network           = "${cloudstack_network.ambari.name}"
    template          = "${var.instance_template.ambari-clientagent}"
    zone              = "${var.vpc_zone}"
    expunge           = true
    depends_on        = ["cloudstack_instance.bastion"]

    connection {
      type              = "ssh"
      host              = "${self.ipaddress}"
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
      "./bootstrap_agent.sh ${var.hostname.ambari-master}.${var.domain_name.zone}",
      "sudo mkdir -p /var/run/ambari-agent/",
      "sudo service firewalld stop",
      "sudo /sbin/chkconfig firewalld off",
      "sudo /sbin/chkconfig ambari-agent on",
      "sudo reboot"
      ]
  }
}
