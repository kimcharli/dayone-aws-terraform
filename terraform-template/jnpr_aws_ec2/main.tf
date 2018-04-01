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


// aws ec2 allocate-address --domain vpc
resource "aws_eip" "default" {
  count = 2
  vpc = true
  network_interface = "${var.interfaces_fxp0_ids[count.index]}"
}

resource "aws_instance" "vsrx" {
  count = 2
  depends_on = ["aws_eip.default"]

  ami = "${var.aws_vsrx_amis[var.aws_region]}"
  instance_type = "${var.vsrx_instance_types[var.aws_region]}"
  disable_api_termination = false
  key_name = "${var.key_name}"

  network_interface {
     device_index = 0
     network_interface_id = "${var.interfaces_fxp0_ids[count.index]}"
  }
  network_interface {
    device_index = 1
    network_interface_id = "${var.interfaces_ge000_ids[count.index]}"
  }

  tags {
    Name = "vsrx-${count.index}-${var.vpc_name}"
  }

}

