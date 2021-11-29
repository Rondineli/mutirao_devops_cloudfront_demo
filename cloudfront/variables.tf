variable "vpc_id" {}
variable "subnet_id" {}
variable "ssh_key" {}

variable "instance_profile" {
  type    = string
  default = "t2.micro"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "short_application_name" {
  type = string
  default = "cf-demo"
}

variable "application" {
  type    = string
  default = "cf-demo"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

