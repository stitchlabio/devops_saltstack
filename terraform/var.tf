variable "aws_region" {
  description = "region"
  default     = "ap-northeast-1"
}

variable "instance_count" {
  description = "Number of instance"
  default     = "2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "tag_name" {
  description = "AWS resource tag Name"
  default = "devops-test01"
}

variable "key_name" {
  description = "Name of AWS key pair"
  default = "devops-tokyo-key"
}

variable "admin_cidr_ingress" {
  description = "CIDR to allow tcp/22 ingress to EC2 instance"
  default     = "0.0.0.0/0"
}