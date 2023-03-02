variable "acm_san" {
    type = list(string)
    default = [ "sonarlab.sworks.net", "sonarlab.internal.sworks.net" ]
}

variable "hosted_zone_id" {
    type        = map
    description = "Publish Zone id in route 53"
    default     = {
        test = "Z2STIX312NJ9CJ"
        prod = "ZYGP0ZZBXVQDJ"
    }
}

variable "app_name" {
    description = "Sonarqube application"
    default = "sonarqube"
}

variable "env" {
    description = "Environment"
    type        = string
    default     = "test"
}

variable "vpc_id" {}

variable "private_subnets" {
    description = "Empty variable as value will be provided from load_balancer module"
}

variable "ec2_instance_id" {
    description = "Empty variable as value will be provided from load_balancer module"
}

variable "app_port" {
    description = "Sonarqube application port"
    type        = number
    default     = 8080
}

variable "lb_port" {
    description = "elb port"
    type        = number
    default     = 443
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
















