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

variable "vpc_net" {}

variable "vpc_vsrx_subnet" { type = "list"}

variable "security_group_fxp0_id" {}

variable "security_group_ge000_id" {}

