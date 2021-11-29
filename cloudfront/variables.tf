variable "vpc_id" {
  type        = string
  description = "Vpc id to place scaling groups and ec2"
}

variable "ssh_key" {
  type        = string
  description = "ssh key name to connect to your ec2 instance"
}

variable "aliases" {
  type = string
  description = "Domain aliases superated by coma: ie: my-cdn.mydomain.com,*.mydomain.com"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate arn, it should match with the aliases configured"
}

variable "instance_type" {
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

