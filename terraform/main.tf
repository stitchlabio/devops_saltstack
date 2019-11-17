# Specify the provider and access details
provider "aws" {
  region = "ap-northeast-1"
}

### Network

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.150.0.0/16"
  tags = {
    Name = "${var.tag_name}-vpc"
 }
}

resource "aws_subnet" "main" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
  
  tags = {
    Name = "${var.tag_name}-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  
  tags = {
    Name = "${var.tag_name}-igw"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  
  tags = {
    Name = "${var.tag_name}-rt"
  }
}

resource "aws_route_table_association" "a" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
}

## SALTMASTER

resource "aws_security_group" "salt_sg" {
  description = "controls access to the application server"
  vpc_id      = "${aws_vpc.main.id}"
  name   = "${var.tag_name}-salt-sg"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535

    cidr_blocks = [
      "${aws_vpc.main.cidr_block}",
    ]
  }
  
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "${var.admin_cidr_ingress}",
    ]
  }
}


data "template_file" "salt_master_user_data" {
  template = "${file("${path.module}/salt_master_user_data")}"
}

resource "aws_instance" "devops_salt_master" {
  vpc_security_group_ids = ["${aws_security_group.salt_sg.id}"]

  key_name                    = "${var.key_name}"
  ami                    = "ami-0f9af249e7fa6f61b"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id = "${element(aws_subnet.main.*.id, 0)}"
  user_data                   = "${data.template_file.salt_master_user_data.rendered}"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "${var.tag_name}-salt-master"
 }
}

## SALTMINION

resource "aws_security_group" "minion_sg" {
  description = "controls access to the application server"
  vpc_id      = "${aws_vpc.main.id}"
  name   = "${var.tag_name}-minion-sg"

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0

    cidr_blocks = [
      "${aws_vpc.main.cidr_block}",
    ]
  }
  
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [
      "${var.admin_cidr_ingress}",
    ]
  }
  
  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

data "template_file" "salt_minion_user_data" {
  template = "${file("${path.module}/salt_minion_user_data")}"
  vars = {
    salt_master_ip   = "${aws_instance.devops_salt_master.private_ip}"
  }
}

resource "aws_instance" "devops_minion_server" {
  vpc_security_group_ids = ["${aws_security_group.minion_sg.id}"]

  key_name                    = "${var.key_name}"
  ami                    = "ami-0f9af249e7fa6f61b"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id = "${element(aws_subnet.main.*.id, 1)}"
  user_data                   = "${data.template_file.salt_minion_user_data.rendered}"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "${var.tag_name}-minion"
 }
}