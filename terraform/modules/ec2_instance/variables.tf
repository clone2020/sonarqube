variable "ssh_keys" {}

variable "secret_key" {
    default = "sonar-secret"
}

variable "app_version" {}

variable "db_dependency" {}

variable "subnet_id" {}

variable "vpc_id" {}

variable "user_data" {}

variable "app_conf" {}

variable "ebs_conf" {}

variable "sys_conf" {}

variable "domain" {
    type = map
    description = "Full domain of the database."
    default = {
        test = "aws-test.sworks.com"
        prod = "aws.sworks.com"
    }
  
}

variable "instance_type" {
    description = "Instance type"
    type = string
}

variable "ssh_port" {
    description = "SSH port to the EC2 number"
    type = number
    default = 22
}

variable "app_port" {
    description = "application port number"
    type = number
    default = 8080
}

variable "data_volume_id" {
    description = "Empty variable as ebs volume id comes from module"
}

variable "app_name" {
    description = "sonarqube application"
    default = "sonarqube"
}

variable "env" {
    description = "Environment"
    type        = string
    default     = "test"
}

variable "scwx_internal_cidr_blocks" {
    description = "CIDR blocks representing internal SCWX networks"
    default = [
        "10.0.0.0/8",
        "172.0.0.0/8",
        "192.168.0.0/16",
        "208.89.44.0/23"
    ]
}