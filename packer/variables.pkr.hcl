variable "domain" {
    description = "Application URL to injenct into config"
    type        = map(string)
    default = {
        "test" = "aws-test.sworks.com"
        "prod" = "aws.sworks.com"
    }
}

variable "env" {
    description = "Environment"
    default     = "test"
}

variable "profile" {
    description = "AWS credentials profile"
    type = map(string)
    default = {
        "test" = "voltron-test"
        "prod" = "voltron-prod"
    }
}

variable "aws_region" {
    description = "Voltron core vpc id"
    type        = string
    default     = "vpc-947747yrhf757hfy"
}

variable "subnet_id" {
    description = "private subnet id"
    type        = string
    default     = "subnet-04as44jf99jla99"
}

variable "instance_type" {
    description = "Instnce type"
    type         = string
    default      = "t2.medium"
}

variable "ssh_username" {
    type    = string
    default = "centos"
}

variable "communicator" {
    type       = string
    default    = "ssh"
}

variable "ami_name" {
    description = "Name of the AMI to be created"
    type        = string
    default     = "packer_AWS {{timestamp}}"
}

variable "virtualization-type" {
    type     = string
    default  = "hvm"
}

variable "ena_support" {
    type = bool
    default = true
}

variable "architecture" {
    type = string
    default = "x86_64"
}

variable "name" {
    description = "The base image"
    type        = string
    default     = "Amazon Linux 2 Kernel 5.10 AMI 2.0*"
}

variable "root-device-type" {
    type   = string
    default = "ebs"
}

variable "most_recent" {
    type   = bool
    default = "true"
}

variable "application_name" {
    description = "The name of the application or service or project to which the resource belongs."
    default = "sonarqube"
}

variable "ami_desc" {
    type     = string
    default  = "Application Server AMI"
}

variable "Name" {
    type    = string
    default = "Centos7 Packer AMI"
}

variable "encrypt" {
    type      = bool
    default   = "true"
}

variable "technical_contact" {
    description = "The email distro of the reponsible squad / team"
    default     = "team@sworks.com"
}

variable "business_unit" {
    description = "The Business Unit associated with the resource. Used for cost allocation and tracking. e.g. Product Engineering"
    default     = "Product Engineering"
}

variable "production" {
    description = "Identitiy whether the resource is in production or not. The combination of Business Unit and this tag will enable accurate finacial tracking."
    type        = bool
    default     = "false"
}