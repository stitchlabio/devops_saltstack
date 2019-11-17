output "salt_master_server_ip" {
  value = "${aws_instance.devops_salt_master.public_ip}"
}

output "salt_minion_server_ip" {
  value = "${aws_instance.devops_minion_server.public_ip}"
}

output "salt_master_log_in" {
  value = "ssh -i ~/environment/${var.key_name}.pem ubuntu@${aws_instance.devops_salt_master.public_ip}"
}