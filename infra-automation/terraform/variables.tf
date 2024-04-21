variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "server_ami" {
  description = "The AMI to use for the server."
  default = "ami-id"
}

variable "instance_type" {
  description = "The instance type of the EC2 instance."
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name of the SSH key to insert in the EC2 instance."
  default     = "mykey.pem"
}
