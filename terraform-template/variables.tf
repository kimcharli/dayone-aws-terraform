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


// the region variable cannot be interpolation. Set it manually
terraform {
//  backend "s3" {
////    encrypt = true
//    key = "pslab/terraform.tfstate"
//
//    bucket = "transit-vsrx-2"
//    region = "us-west-2"
//
//  }
}


variable "aws_region" {
  type = "map"
  default = {
    tvpc1 = "us-west-2"
  }
}

variable "vpc_names" {
  type = "map"
  default = {
    tvpc1 = "transit-vpc1"
  }
}

variable "vpc_nets" {
  type = "map"
  default = {
    tvpc1 = "10.10.128.0/17"
  }
}

variable "vpc_vsrx_subnet" {
  type = "map"
  default = {
    tvpc1 = [ "10.10.128.0/24", "10.10.129.0/24" ]
  }
}


variable "aws_vsrx_amis" {
  type = "map"
  default = {
    us-west-2 = "ami-e42db19c"
  }
}

variable "vsrx_instance_types" {
  description = "Flavor of vSRX image"
  type = "map"
  default = {
    us-west-2 = "c4.xlarge"
  }
}

variable "vsrx_user" {
  default = "root"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "day-one"
}

variable "vsrx_host_name" {
  type = "map"
  default = {
    tvpc1 = [ "host-transit1-1", "host-transit1-2"]
  }
}


