provider "cloudstack" {
    api_url = "${var.api_url}"
    api_key = "${var.api_key}"
    secret_key = "${var.secret_key}"
}

/* Define our vpc */
resource "cloudstack_vpc" "main" {
    name = "${var.vpc_name}"
    cidr = "${var.vpc_cidr_block}"
    vpc_offering = "${var.vpc_offering}"
    zone = "${var.vpc_zone}"
}
