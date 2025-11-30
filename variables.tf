variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "az" {
  description = "Availability Zone"
  default     = "ap-south-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  default     = "ami-0f5ee92e2d63afc18"
}

variable "volume_size" {
  description = "Root EBS volume size"
  default     = 20
}
