Amazon Linux Jumpbox Module
==============================

A Terraform module to provide a Linux jumpbox running Amazon Linux that provides basic default applications such as a Chromium web browser and RDP access using xrdp.

![Desktop Picture](/images/1.png)

Module Input Variables
--------------------------

- `aws_region` - AWS Region location of jumpbox server.
- `vpc_id` - ID of the VPC where the jumpbox server will reside.
- `ami_id` - ID of AMI by Jumpbox. Defaults to latest Amazon Linux AMI.
- `key_pair` - Name of key pair to SSH into jumpbox server.
- `subnet_id` - ID of subnet where the jumpbox will reside.
- `private_ip` - Private IP of the jumpbox used for eth0.
- `default_tags` - Tags assigned to jumpbox instance.
- `name_prefix` - Prefix added to name tags of provisioned resources.
- `default_username` - Name of the default user account users will use to access the jumpbox.
- `default_password` - Default password for default user account. Randomly generated if empty.
- `include_public_ip` - Adds an EIP to the jumpbox server. true or false.
- `instance_type` - Size of jumpbox's EC2 instance.
- `user_data` - List of commands to be executed at startup type.
- `ingress_ports` - A map/dictionary of ports allowed to connect to the jumpbox. Default is 22(SSH) and RDP(3389).

Usage
-----

```hcl
module "jumpbox" {
  source           = "git@github.com:wwt/linux-jumpbox-tf-template"
  name_prefix      = "${terraform.workspace}-"

  aws_region       = "us-west-1"
  key_pair         = "test-key"
  vpc_id           = "vpc-09072e62ba8e0dfc0"
  subnet_id        = "subnet-0c1c74a9b2a25646c"
  private_ip       = "10.128.30.100"
}
```

Outputs
=======

 - `jumpbox_ip` - Public IP of jumpbox server.
 - `jumpbox_username` - Username to access jumpbox server.
 - `jumpbox_password` - Password to access jumpbox server.


