
# files

tree
```
.
└── terraform
    ├── README.md
    ├── jnpr_aws_ec2
    │   ├── files
    │   │   ├── jet
    │   │   │   └── route_commander.py
    │   │   ├── op
    │   │   │   └── set-route-worker.py
    │   │   ├── spoke-vsrx.tpl
    │   │   ├── transit-side-tunnel.tpl
    │   │   ├── transit-vsrx-0.tpl
    │   │   ├── transit-vsrx-1.tpl
    │   │   ├── transit-vsrx.tpl
    │   │   └── wait-for-instance-ok.sh
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── security_group.tf
    │   └── variables.tf
    ├── jnpr_aws_global
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── jnpr_aws_vpc
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── main.tf
    ├── outputs.tf
    ├── redhat-terraform.md
    └── variables.tf

```

# terraform client setup

## build client
refer to [redhat-terraform.md] for the steps to bring up RHEL for terraform

## copy over the terraform repo to the client
example of incremental copy
```
rsync -avz -e ssh ../terraform ec2-user@34.214.40.102:

```


# work on terraform client

## configure profile per VPC

In the example below, tvpc1 and svpc1 are the VPC
```
[ec2-user@ip-172-31-14-165 terraform]$ aws configure --profile tvpc1
AWS Access Key ID [None]: WWWWWWWWWWWWWWWWWWWW
AWS Secret Access Key [None]: YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
Default region name [None]: us-west-2
Default output format [None]: json
[ec2-user@ip-172-31-14-165 terraform]$
[ec2-user@ip-172-31-14-165 terraform]$ aws configure --profile svpc1
AWS Access Key ID [None]: XXXXXXXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
Default region name [None]: us-gov-west-1
Default output format [None]: json
[ec2-user@ip-172-31-14-165 terraform]$
```

```
cd terraform
```

review variables.tf for the target VPC which will be referred as "workspace".

Once
- get provider
```
terraform provider
```


- load modules with terraform get
```
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform get
Get: file:///home/ubuntu/aws-transit-vpc-vsrx-terraform]/terraform/jnpr_aws_global
Get: file:///home/ubuntu/aws-transit-vpc-vsrx-terraform]/terraform/jnpr_aws_vpc
Get: file:///home/ubuntu/aws-transit-vpc-vsrx-terraform]/terraform/jnpr_aws_ec2
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$

```
- and init
```
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform init
Downloading modules...

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "template" (1.0.0)...
- Downloading plugin for provider "aws" (1.2.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 1.2"
* provider.template: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$
```


## the VPC selection is based on workspace

For example, choose workspace tvpc1 to providion vpc with name "transit-vpc1" in region "us-west-2".
```
// just for reference
variable "aws_regions" {
  type = "map"
  default = {
    tvpc1 = "us-west-2"
    svpc1 = "us-gov-west-1"
  }
}


variable "vpc_names" {
  type = "map"
  default = {
    tvpc1 = "transit-vpc1"
    svpc1 = "spoke-vpc1"
  }
}
```

- *update transit_public_key and tvpc_ge000_public_ip once tvpc has been done*

- choose workspace
```
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform workspace select svpc1
Switched to workspace "svpc1".
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform workspace show
svpc1
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$
```


- create one when it doesn't exist
```
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform workspace new tvpc1
Created and switched to workspace "tvpc1"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform workspace show
tvpc1
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform workspace list
  default
  svpc1
* tvpc1

ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$

```

- do plan and review them
```
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

...

      service_name:                                        "com.amazonaws.us-gov-west-1.s3"
      vpc_id:                                              "${aws_vpc.default.id}"


Plan: 32 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$

```


- and finally apply
```
ubuntu@ip-10-0-0-50:~/aws-transit-vpc-vsrx-terraform]/terraform$ terraform apply
data.template_file.vsrx-init: Refreshing state...
data.aws_iam_role.configured-vsrx-ec2: Refreshing state...
data.aws_availability_zones.azs: Refreshing state...
module.jnpr_aws_global.data.aws_iam_role.configured-vsrx-ec2: Refreshing state...
module.jnpr_aws_global.aws_iam_role.vsrx-ec2: Creating...
```

- use show to verify results
```
terraform show
```

- use destroy to remove it
```
terraform workspace destroy
```


## apply configuration in transit

```
load replace /var/db/scripts/op/spoke-spoke-vpc1.conf
```


## TODO: add peer in security group
This is not required at the moment
add local ip to security group


### spoke vsrx test in CLI from local or remote

system scripts is configured to use python and allow-url-for-python
```
ckim-mbp:spoke-vpc ckim$ ssh icenes@s-vsrx-1 op url /var/db/scripts/op/set-route-worker.py
```


flapping test to trigger transit side event
```
cli -c "edit ; set interfaces st0.203 disable ; commit confirmed 1 ; exit ; exit "
```


### configured SNAT in spoke vSRX for API
may be configured all in default routing-instance instead
commit at +3 minutes



### from transit vSRX

load replace /var/db/scripts/op/spoke-spoke-vpc1.conf

used ADV-GENERTE-PREPEND instead of DV-DEFAULT-PREPEND


### misc

- cloud init related configuration
```
ckim-mbp:spoke-vpc ckim$ scp root@52.9.227.74:/config/default.conf ../files
default.conf                                                                                                                                                                                           100% 2369    16.5KB/s   00:00
ckim-mbp:spoke-vpc ckim$ scp root@52.9.227.74:/config/juniper.conf.gz ../files
juniper.conf.gz
ckim-mbp:spoke-vpc ckim$ scp root@52.9.227.74:/etc/setup_vsrx ../files
setup_vsrx                                                                                                                                                                                             100%   23KB  36.0KB/s   00:00
ckim-mbp:spoke-vpc ckim$ scp root@52.9.227.74:/etc/config/vsrx.base.conf ../files
vsrx.base.conf                                                                                                                                                                                         100% 2804    22.0KB/s   00:00
ckim-mbp:spoke-vpc ckim$

```

- /var/host in vSRX
```
root@% ls -l /var/host/
total 1560
-rwxr-xr-x  1 root  wheel      24 Oct 23 21:12 JUNOS_VERIEXEC_FILES
-rwxr-xr-x  1 root  wheel     257 Oct 23 21:12 cpuboardideeprom.dat
-rwxr-xr-x  1 root  wheel     167 Oct 23 21:12 default-flex.conf
-rwxr-xr-x  1 root  wheel    2369 Oct 23 21:12 default.conf
-rwxr-xr-x  1 root  wheel    4921 Oct 23 21:12 dst_cpu_subsystem.conf
-rwxr-xr-x  1 root  wheel    6193 Oct 23 21:12 dst_pfe_bcm.conf
-rwxr-xr-x  1 root  wheel   18014 Oct 23 21:12 dst_pfe_capacity.conf
-rwxr-xr-x  1 root  wheel    1873 Oct 23 21:12 dst_pfe_optics.conf
-rwxr-xr-x  1 root  wheel     836 Oct 23 21:12 dst_pfe_pic.conf
-rwxr-xr-x  1 root  wheel     241 Oct 23 21:12 fpcboardideeprom.dat
-rwxr-xr-x  1 root  wheel   23047 Oct 23 21:12 init.conf
-rwxr-xr-x  1 root  wheel   31270 Oct 23 21:12 libschema-filter-dd.tlv
-rwxr-xr-x  1 root  wheel     257 Oct 23 21:12 mainboardideeprom.dat
-rwxr-xr-x  1 root  wheel      70 Oct 23 21:12 manifest
-rwxr-xr-x  1 root  wheel    5211 Oct 23 21:12 manifest.ecerts
-rwxr-xr-x  1 root  wheel     280 Oct 23 21:12 manifest.esig
-rwxr-xr-x  1 root  wheel     238 Oct 23 21:12 manifest.loader
-rwxr-xr-x  1 root  wheel     456 Oct 23 21:12 pfe.conf
-rwxr-xr-x  1 root  wheel    5725 Oct 23 21:12 pfe_params_bcm.conf
-rwxr-xr-x  1 root  wheel  585520 Oct 23 21:12 pvidbschema.bin
-rwxr-xr-x  1 root  wheel   61127 Oct 23 21:12 pvidbschema.conf
-rwxr-xr-x  1 root  wheel    3817 Oct 23 21:12 rc.platform.tvp
-rwxr-xr-x  1 root  wheel    5178 Oct 23 21:12 rc.pre-config.tvp
-rwxr-xr-x  1 root  wheel    2705 Oct 23 21:12 rc.shutdown.tvp
-rwxr-xr-x  1 root  wheel     416 Oct 23 21:12 rsa_id.pub
-rwxr-xr-x  1 root  wheel    1878 Oct 23 21:12 schema-filter.cmd.dd
-rwxr-xr-x  1 root  wheel    1937 Oct 23 21:12 schema-filter.cnf.dd
-rwxr-xr-x  1 root  wheel     208 Oct 23 21:12 vmware_pci_static_order
root@%
root@% kenv
LINES="24"
acpi_load="YES"
autoboot_delay="2"
boot.status="0x80000"
boot_serial="YES"
bootfile="/kernel;/kernel.old"
comconsole_speed="9600"
console="comconsole vidconsole"
currdev="disk0s1a:"
hint.acpi.0.oem="BOCHS "
hint.acpi.0.revision="1"
hint.acpi.0.rsdt="0x3d0fe4b0"
interpret="OK"
kern.aps_lapic_timer_interrupt_enable="0"
kern.bsp_handle_all_interrupts="1"
kern.hz="200"
kern.ipc.nmbclusters="640"
kern.lapic_timer_use_hz="1"
kern.lockable_mem_ratio="1"
kern.maxdsiz="1073741824"
kern.maxfiles="2500"
kern.maxproc="532"
kern.maxusers="16"
kernel="/kernel"
kernel_options=""
kernelname="/kernel"
loaddev="disk0s1a:"
loader.name="FreeBSD/i386 bootstrap loader"
loader.version="1.2"
mac_ifoff="NO"
machdep.hyperthreading_allowed="1"
module_path="/boot//kernel;/boot/modules"
retype="185"
smbios.bios.reldate="01/01/2011"
smbios.bios.vendor="Bochs"
smbios.bios.version="Bochs"
smbios.chassis.maker="Bochs"
smbios.memory.enabled="1000448"
smbios.socket.enabled="1"
smbios.socket.populated="1"
smbios.system.maker="Bochs"
smbios.system.product="ipaddr=10.20.1.11/24;gateway=10.20.1.1"
smbios.system.uuid="ec2d12ac-6684-d6ec-ab1a-e983de81a50b"
smbios.version="2.4"
vfs.root.mountfrom="ufs:/dev/ad0s1a"
root@%
root@% curl http://169.254.169.254/latest/dynamic/instance-identity/document/
{
  "devpayProductCodes" : null,
  "privateIp" : "10.20.1.11",
  "availabilityZone" : "us-west-1a",
  "version" : "2010-08-31",
  "region" : "us-west-1",
  "instanceId" : "i-020ea5b828694fd0b",
  "billingProducts" : null,
  "instanceType" : "c4.xlarge",
  "accountId" : "932087982216",
  "architecture" : "x86_64",
  "kernelId" : null,
  "ramdiskId" : null,
  "imageId" : "ami-8a665bea",
  "pendingTime" : "2017-10-23T21:10:46Z"
}
root@%

root@% curl http://169.254.169.254/latest/meta-data/hostname
ip-10-20-1-11.us-west-1.compute.internalroot@% curl http://169.254.169.254/latest/meta-data/network/
interfaces/
root@% curl http://169.254.169.254/latest/meta-data/network/interfaces/
macs/
root@% curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/
02:91:d3:09:63:0c/
02:9f:2d:e5:6a:42/
root@% curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/02:91:d3:09:63:0c/
device-number
interface-id
ipv4-associations/
local-hostname
local-ipv4s
mac
owner-id
public-hostname
public-ipv4s
security-group-ids
security-groups
subnet-id
subnet-ipv4-cidr-block
vpc-id
vpc-ipv4-cidr-blocks
root@% curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/02:91:d3:09:63:0c/vpc-id
vpc-934874f7
root@% curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/02:91:d3:09:63:0c/public-ipv4s
52.9.227.74
root@%
partition
root@% curl http://169.254.169.254/latest/meta-data/services/domain/
amazonaws.com
root@%
oot@% curl http://169.254.169.254/latest/user-data/
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title>404 - Not Found</title>
 </head>
 <body>
  <h1>404 - Not Found</h1>
 </body>
</html>
root@%


security-credentials/root@% curl http://169.254.169.254/latest/meta-data/iam/info
{
  "Code" : "Success",
  "LastUpdated" : "2017-10-24T01:00:27Z",
  "InstanceProfileArn" : "arn:aws:iam::932087982216:instance-profile/ckim-profile",
  "InstanceProfileId" : "AIPAI63EFTSI6AUI7R72Q"
}root@%
oot@% curl http://169.254.169.254/latest/user-data/
#junos-config

testing

root@%



/usr/sbin/mgd commit $base_config >/var/log/messages 2>&1


```


### get configuation

```
root@% curl -s http://169.254.169.254/latest/user-data -o user-data
root@% echo $?
0
root@%
```




### update s3 from develop/repo
not implemented in this phase

aws s3 sync ../files/tvpc-repo1/instances/ramwC01_RTIC-Transit-1/ s3://ckim-terraform/tvpc-repo1/instances/ramwC01_RTIC-Transit-1/

### jet related configuration

```
system {
    scripts {
        language python;
    }
    services {
        extension-service {
            notification {
                 max-connections 20;
                 allow-clients {
                    address [ 66.129.241.0/24 128.0.0.1 127.0.0.1 0.0.0.0/0 ];
                }
            }
        }
    }
    extensions {
        extension-service {
            application {
                file route_commander.py {
                    daemonize;
                    username root;
                }
            }
        }
    }
}
interfaces {
    lo0 {
        unit 100 {
            description "ICE management loopback";
            family inet {
                address 10.150.255.1/32 {
                    primary;
                }
                address 127.0.0.1/32;
            }
        }
    }
}
```

- some jet reqlated commands (just for reference and may be irelevant to current implementaion)
```
/var/db/scripts/jet/hello.py
print "hello"

root@TRANSIT-PEER-2> request extension-service start hello.py
Extension-service application 'hello.py' started with PID: 57465
hello

root@TRANSIT-PEER-2>

root@TRANSIT-PEER-1# run show extension-service status all
Extension service application details:
Name : route_commander
Process-id: 16964
Stack-Segment-Size: 8388608B
Data-Segment-Size: 134217728B



show extension-service status hello.py

root@TRANSIT-PEER-2% netstat -an | grep 1883 | grep LISTEN
tcp4       0      0  *.41883                                       *.*                                           LISTEN
tcp4       0      0  *.1883                                        *.*                                           LISTEN
tcp6       0      0  *.1883                                        *.*                                           LISTEN
root@TRANSIT-PEER-2%
```

