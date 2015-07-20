provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "default" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.key_file)}"
}

/* Define our vpc */
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "Ambari VPC"
  }
}

resource "aws_vpc_dhcp_options" "default" {
    domain_name = "${var.domain_name}"
    domain_name_servers = ["10.0.0.2"]
    tags {
        Name = "DHCP Options"
    }
}

resource "aws_vpc_dhcp_options_association" "default" {
    vpc_id = "${aws_vpc.default.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}
