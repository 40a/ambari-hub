resource "cloudstack_instance" "ambari-master" {
    name              = "${var.instance_name.ambari-master}"
    service_offering  = "${var.instance_type.ambari-master}"
    network           = "${cloudstack_network.ambari.name}"
    template          = "${var.instance_template.ambari-master}"
    zone              = "${var.vpc_zone}"
    expunge           = true
    depends_on        = "cloudstack_instance.bastion"
}

resource "cloudstack_disk" "ambari-master" {
  name             = "ambari-master-data1"
  attach           = "true"
  disk_offering    = "${var.disk_type.large}"
  virtual_machine  = "${cloudstack_instance.ambari-master.name}"
  zone             = "${var.vpc_zone}"
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
    depends_on = ["cloudstack_instance.ambari-master", "cloudstack_disk.ambari-master"]

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
  provisioner "remote-exec" {
      inline = [
      "sudo parted /dev/xvdb mkpart ext4 0% 100%",
      "sudo mkfs -t ext4 /dev/xvdb1",
      "sudo mkdir /hadoop",
      "echo '/dev/xvdb1    /hadoop ext4   defaults,noatime    0  2' | sudo tee --append /etc/fstab",
      "sudo mount -a",
      "chmod +x bootstrap_server.sh",
      "chmod +x bootstrap_agent.sh",
      "sudo cp agent-hostname-detector.sh /etc/ambari-agent",
      "sudo chmod +x /etc/ambari-agent/agent-hostname-detector.sh",
      "./bootstrap_server.sh ${var.hostname.ambari-master}.${var.domain_name.sub}.${var.domain_name.zone} ${var.hostname.ambari-master}.${var.domain_name.sub}.${var.domain_name.zone}",
      "sudo cp -f ambari-agent.ini /etc/ambari-agent/conf",
      "./bootstrap_agent.sh ${var.hostname.ambari-master}.${var.domain_name.sub}.${var.domain_name.zone} ${var.hostname.ambari-master}.${var.domain_name.sub}.${var.domain_name.zone}",
      "sudo mkdir -p /var/run/ambari-agent/",
      "sudo /sbin/chkconfig ambari-agent on",
      "sudo /sbin/chkconfig ambari-server on",
      "sudo reboot"
      ]
  }
}