/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_subnet" "hadoop" {
  vpc_id                  = "${aws_vpc.default.id}"
  count                   = "${length(split(",", var.hadoop_subnets_cidr))}"
  availability_zone       = "${element(var.subnet_availability_zone, count.index)}"
  cidr_block              = "${element(split(",", var.hadoop_subnets_cidr), count.index)}"
  map_public_ip_on_launch = false
  depends_on              = ["aws_internet_gateway.public"]
  tags {
    Name = "Ambari Private AZ-a subnet"
  }
}

# Route table for the internet (as in, DEFAULT GATEWAY to 0.0.0.0/0)
resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }
  tags {
    Name = "Default gateway to the almighty interwebz."
  }
}

/*
resource "aws_main_route_table_association" "public" {
    vpc_id         = "${aws_vpc.default.id}"
    route_table_id = "${aws_route_table.internet.id}"
}
*/

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.hadoop_subnets_cidr))}"
  subnet_id      = "${element(aws_subnet.hadoop.*.id, count.index)}"
  route_table_id = "${aws_route_table.internet.id}"
}
