/* Default security group */
resource "aws_security_group" "default" {
  name        = "Fusang Analytics Security Group"
  description = "Default security group."
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
    cidr_blocks = ["${var.security_group.karsten}"]
  }

  # Allows all inbound traffic from the CIDR.
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  # Allows all outbound traffic to internet.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "Ambari security group"
  }
}