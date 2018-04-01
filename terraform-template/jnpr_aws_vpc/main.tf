//# <*******************
//#
//# Copyright 2017 Juniper Networks, Inc. All rights reserved.
//# Licensed under the Juniper Networks Script Software License (the "License").
//# You may not use this script file except in compliance with the License, which is located at
//# http://www.juniper.net/support/legal/scriptlicense/
//# Unless required by applicable law or otherwise agreed to in writing by the parties, software
//# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//#
//# *******************>


resource "aws_vpc" "default" {
  cidr_block       = "${var.vpc_net}"

  tags {
    Name = "${var.vpc_name}"
  }
}


data "aws_availability_zones" "azs" {}

resource "aws_subnet" "vsrx-subnet" {
  count = 2
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "${var.vpc_vsrx_subnet[count.index]}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"

  tags {
    Name = "vsrx-subnet${count.index}-${var.vpc_name}"
  }
}



resource "aws_internet_gateway" "default" {
  vpc_id     = "${aws_vpc.default.id}"

  tags {
    Name = "igw-${var.vpc_name}"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}


resource "aws_network_interface" "fxp0" {
  count = 2
  subnet_id       = "${aws_subnet.vsrx-subnet.*.id[count.index]}"
  security_groups = ["${var.security_group_fxp0_id}"]
}

resource "aws_network_interface" "ge000" {
  count = 2
  subnet_id       = "${aws_subnet.vsrx-subnet.*.id[count.index]}"
  security_groups = ["${var.security_group_fxp0_id}", "${var.security_group_ge000_id}"]
  source_dest_check = false

}



