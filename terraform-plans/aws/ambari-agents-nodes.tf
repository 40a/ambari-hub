/* Ambari master instances */
resource "aws_instance" "ambari-agent" {
  instance_type     = "${var.instance_type.agent}"
  ami               = "${var.instance_ami.ambari-agent}"
  count             = "${var.ambari-agents}"
  key_name          = "${aws_key_pair.default.key_name}"
  subnet_id         = "${aws_subnet.public.id}"
  source_dest_check = false
  security_groups   = ["${aws_security_group.default.id}"]
  tags {
    Name     = "${var.hostname.agents}"
    Role     = "Ambari Agent ${count.index}."
  }

  connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "${var.bootstrap_user}"
      key_file = "${var.private_key}"
  }
  provisioner "file" {
      source = "bootstrap_agent.sh"
      destination = "../../scripts/terraform/bootstrap_agent.sh"
  }

  provisioner "file" {
      source = "agent-hostname-detector.sh"
      destination = "../../scripts/terraform/agent-hostname-detector.sh"
  }

  provisioner "file" {
      source = "ambari-agent.ini"
      destination = "../../files/terraform/ambari-agent.ini"
  }

# The part below can be done MUCH cleaner, for now it works but we're doing inline commands with scripts, it's just plain ugly.

  provisioner "remote-exec" {
      inline = [
      "chmod +x ~/bootstrap_agent.sh",
      "sudo cp agent-hostname-detector.sh /etc/ambari-agent",
      "sudo chmod +x /etc/ambari-agent/agent-hostname-detector.sh",
      "sudo cp -f ambari-agent.ini /etc/ambari-agent/conf",
      "~/bootstrap_agent.sh ${var.hostname.agents}-${count.index}.${var.domain_name} ${var.hostname.master}.${var.domain_name}",
      "echo ${self.private_ip} ${var.hostname.agents}-${count.index}.${var.domain_name} | sudo tee --append /etc/hosts",
      "sudo mkdir -p /var/run/ambari-agent/",
      "sudo /sbin/chkconfig ambari-agent on",
      "sudo service ambari-agent start"
      ]
  }
#  depends_on = "aws_route53_record.ambari_masters_private"
}





