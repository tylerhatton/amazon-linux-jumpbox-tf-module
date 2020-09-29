output "jumpbox_ip" {
  value       = var.include_public_ip == true ? aws_eip.jumpbox_mgmt[0].public_ip : ""
  description = "The mgmt IP of the Jumpbox."
}

output "jumpbox_username" {
  value       = var.default_username
  description = "The username for the jumpbox."
}

output "jumpbox_password" {
  value       = var.default_password != "" ? var.default_password : random_password.default_password.result
  description = "The password for the jumpbox."
}
