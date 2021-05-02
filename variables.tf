variable "vpc_id" {
  type = string
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "key_pair" {
  type = string
  default = ""
}

variable "subnet_id" {
  type = string
}

variable "private_ip" {
  type = string
}

variable "default_tags" {
  type = map
  default = {}
}

variable "name_prefix" {
  type    = string
  default = ""
}

variable "default_username" {
  type    = string
  default = "lab-user"
}

variable "default_password" {
  type    = string
  default = ""
}

variable "include_public_ip" {
  default = true
}

variable "instance_type" {
  type    = string
  default = "t2.small"
}

variable "user_data" {
  type    = string
  default = ""
}

variable "ingress_ports" {
  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 3389
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}