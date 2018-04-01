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

output "vpc_default_id" {
  value = "${aws_vpc.default.id}"
}

output "interfaces_fxp0_ids" {
  value = "${aws_network_interface.fxp0.*.id}"
}

output "interfaces_ge000_ids" {
  value = "${aws_network_interface.ge000.*.id}"
}

output "fxp0_ip" {
  value = "${aws_network_interface.fxp0.*.private_ip}"
}

output "ge000_ip" {
  value = "${aws_network_interface.ge000.*.private_ip}"
}
