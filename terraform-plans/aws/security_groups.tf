/* Default security group */
resource "aws_security_group" "default" {
  name        = "Ambari-SecurityGroup"
  description = "Default security group that allows all traffic"
  vpc_id      = "${aws_vpc.default.id}"

  # Allows inbound and outbound traffic from all instances in the VPC.
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  # Allows all inbound traffic from the CIDR.
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["${var.security_group.cidr_blocks}"]
  }

  # Allows all outbound traffic to internet.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "Ambari-SecurityGroup"
  }
}


/* 
resource "aws_security_group_rule" "allow_all" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.default.id}"
    self = true
}
*/