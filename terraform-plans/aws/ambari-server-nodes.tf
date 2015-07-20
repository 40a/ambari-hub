/* Ambari master instances */
resource "aws_instance" "ambari-master" {
  instance_type     = "${var.instance_type.ambari}"
  ami               = "${var.instance_ami.ambari_server}"
  key_name          = "${aws_key_pair.default.key_name}"
  subnet_id         = "${aws_subnet.public.id}"
  source_dest_check = false
  security_groups   = ["${aws_security_group.default.id}"]
  tags {
    Name     = "${var.hostname.master}"
    Role     = "Ambari Master server."
    URL      = "http://${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}:8080"
  }

  connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "centos"
      key_file = "${var.private_key}"
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
      "chmod +x bootstrap_server.sh",
      "chmod +x bootstrap_agent.sh",
      "sudo cp agent-hostname-detector.sh /etc/ambari-agent",
      "sudo chmod +x /etc/ambari-agent/agent-hostname-detector.sh",
      "./bootstrap_server.sh ${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone} ${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}",
      "sudo cp -f ambari-agent.ini /etc/ambari-agent/conf",
      "./bootstrap_agent.sh ${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone} ${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}",
      "sudo mkdir -p /var/run/ambari-agent/",
      "sudo /sbin/chkconfig ambari-agent on",
      "sudo /sbin/chkconfig ambari-server on",
      "sudo reboot"
      ]
  }
}