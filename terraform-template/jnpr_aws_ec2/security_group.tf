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


resource "aws_security_group" "fxp0" {
  name        = "fxp0"
  description = "Allow ssh traffic"
  vpc_id = "${var.jnpr_vpc_id}"

}

// add client public ip in security group rule
// in case of failure, put the my public source ip manually below
data "http" "ip" {
  url = "http://icanhazip.com"
}

resource "aws_security_group_rule" "ssh-client" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.fxp0.id}"
  cidr_blocks = [ "${chomp(data.http.ip.body)}/32"]
}
resource "aws_security_group_rule" "ssh-fxp0" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.fxp0.id}"
  source_security_group_id = "${aws_security_group.fxp0.id}"
}

resource "aws_security_group_rule" "fxp0-out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.fxp0.id}"
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group" "ge-000" {
  name        = "ge-000"
  description = "Allow tunnel traffic"
  vpc_id     = "${var.jnpr_vpc_id}"

}

resource "aws_security_group_rule" "isakmp" {
  type = "ingress"
  from_port = 500
  to_port = 500
  protocol = "udp"
  security_group_id = "${aws_security_group.ge-000.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ipsec-nat" {
  type = "ingress"
  from_port = 4500
  to_port = 4500
  protocol = "udp"
  security_group_id = "${aws_security_group.ge-000.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "esp" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = 50
  security_group_id = "${aws_security_group.ge-000.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ah" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = 51
  security_group_id = "${aws_security_group.ge-000.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ge000-out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ge-000.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

