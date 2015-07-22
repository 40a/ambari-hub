# ebs block store (/dev/sdf) will actually (internally on the instance) be called /dev/xvdf

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
    Name            = "${var.hostname.agents}-${count.index}"
    Role            = "Ambari Agent ${count.index}."
  }
  root_block_device {
  encrypted               = "${var.root_block_device.encrypted}"
  volume_size             = "${var.root_block_device.volume_size}"
  iops                    = "${var.root_block_device.iops}"
  delete_on_termination   = "${var.root_block_device.delete_on_termination}"
  }
  ebs_block_device {
    device_name           = "${var.ebs_block_device.device_name}"
    encrypted             = "${var.ebs_block_device.encrypted}"
    volume_type           = "${var.ebs_block_device.volume_type}"
    volume_size           = "${var.ebs_block_device.volume_size}"
    iops                  = "${var.ebs_block_device.iops}"
    delete_on_termination = "${var.ebs_block_device.delete_on_termination}"
  }

  connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "${var.bootstrap_user}"
      key_file = "${var.private_key}"
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

# The part below can be done MUCH cleaner, for now it works but we're doing inline commands with scripts, it's just plain ugly.

  provisioner "remote-exec" {
      inline = [
      "sudo mkfs -t ext4 ${var.ebs_block_device.instance_volume_name}",
      "sudo mkdir /hadoop",
      "echo '${var.ebs_block_device.instance_volume_name}    /hadoop ext4   defaults,noatime    0  2' | sudo tee --append /etc/fstab",
      "sudo mount -a",
      "chmod +x bootstrap_agent.sh",
      "sudo cp agent-hostname-detector.sh /etc/ambari-agent",
      "sudo chmod +x /etc/ambari-agent/agent-hostname-detector.sh",
      "sudo cp -f ambari-agent.ini /etc/ambari-agent/conf",
      "./bootstrap_agent.sh ${var.hostname.agents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone} ${var.hostname.master}.${var.domain_name.sub}.${var.domain_name.zone}",
      "echo ${self.private_ip} ${var.hostname.agents}-${count.index}.${var.domain_name.sub}.${var.domain_name.zone} | sudo tee --append /etc/hosts",
      "sudo mkdir -p /var/run/ambari-agent/",
      "sudo /sbin/chkconfig ambari-agent on",
      "sudo service ambari-agent start"
      ]
  }
  depends_on = "aws_route53_record.ambari_masters_private"
}





