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

provider "aws" {
//  access_key = "ACCESS_KEY_HERE"
//  secret_key = "SECRET_KEY_HERE"
  region = "${var.aws_region[terraform.workspace]}"
}


// module can be in s3 like "terrabucket.s3-us-gov-west-1.amazonaws.com/aws_vpc.zip
module "jnpr_aws_vpc" {
  source = "jnpr_aws_vpc"

  aws_region = "${var.aws_region[terraform.workspace]}"
  vpc_name = "${var.vpc_names[terraform.workspace]}"
  vpc_net = "${var.vpc_nets[terraform.workspace]}"
  vpc_vsrx_subnet="${var.vpc_vsrx_subnet[terraform.workspace]}"
  security_group_fxp0_id = "${module.jnpr_aws_ec2.security_group_fxp0_id}"
  security_group_ge000_id = "${module.jnpr_aws_ec2.security_group_ge000_id}"
}

module "jnpr_aws_ec2" {
  source = "jnpr_aws_ec2"

  aws_region = "${var.aws_region[terraform.workspace]}"
  vpc_name = "${var.vpc_names[terraform.workspace]}"
  jnpr_vpc_id = "${module.jnpr_aws_vpc.vpc_default_id}"
  interfaces_fxp0_ids = "${module.jnpr_aws_vpc.interfaces_fxp0_ids}"
  interfaces_ge000_ids = "${module.jnpr_aws_vpc.interfaces_ge000_ids}"
  aws_vsrx_amis = "${var.aws_vsrx_amis}"
  vsrx_instance_types = "${var.vsrx_instance_types}"
  vsrx_user = "${var.vsrx_user}"
  key_name = "${var.key_name}"
}

