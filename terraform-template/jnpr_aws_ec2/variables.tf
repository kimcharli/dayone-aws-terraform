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

variable "aws_region" {}
variable "vpc_name" {}
variable "key_name" {}
variable "vsrx_user" {}
variable "jnpr_vpc_id" {}
variable "aws_vsrx_amis" { type = "map" }
variable "vsrx_instance_types" { type = "map" }
variable "interfaces_fxp0_ids" { type = "list" }
variable "interfaces_ge000_ids" { type = "list" }
