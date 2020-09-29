resource "random_password" "default_password" {
  length = 16
  special = false
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars = {
    username    = var.default_username
    password    = var.default_password != "" ? var.default_password : random_password.default_password.result
    name_prefix = var.name_prefix
    user_data   = var.user_data
  }
}

data "aws_ami" "amazon_linux_image" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jumpbox" {
  ami                  = var.ami_id == "" ? data.aws_ami.amazon_linux_image.id : var.ami_id
  instance_type        = var.instance_type
  user_data            = data.template_file.user_data.rendered
  key_name             = var.key_pair != "" ? var.key_pair : null

  network_interface {
    network_interface_id = aws_network_interface.jumpbox_mgmt.id
    device_index         = 0
  }

  tags = merge(map("Name", "${var.name_prefix}jumpbox"), var.default_tags)
}

resource "aws_eip" "jumpbox_mgmt" {
  count                     = var.include_public_ip == true ? 1 : 0
  vpc                       = true
  network_interface         = aws_network_interface.jumpbox_mgmt.id
  associate_with_private_ip = var.private_ip

  tags = merge(map("Name", "${var.name_prefix}jumpbox"), var.default_tags)

  depends_on = [aws_instance.jumpbox]
}

resource "aws_network_interface" "jumpbox_mgmt" {
  subnet_id                   = var.subnet_id
  security_groups             = [aws_security_group.jumpbox.id]
  private_ips                 = [var.private_ip]

  tags = merge(map("Name", "${var.name_prefix}jumpbox"), var.default_tags)
}

data "aws_network_interface" "jumpbox_mgmt" {
  id = aws_network_interface.jumpbox_mgmt.id
}

resource "aws_security_group" "jumpbox" {
  name        = "${var.name_prefix}jumpbox"
  description = "Allow inbound ssh and rdp traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}