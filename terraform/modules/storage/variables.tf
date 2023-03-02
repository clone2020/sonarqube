variable "az" {
    description = "availabulity zone for EBS"
    type        = string
    default     = "us-east-1a"
}

variable "ebs_size" {
    description = "EBS size in Gb"
    type        = number
    default     = 10
}

variable "vol_type" {
    description = "ebs volume type"
    default = "gp3"
}

variable "app_name" {
    description = "Sonarqube application"
    default = "sonarqube"
}

variable "env" {
    description = "environment like test, staging etc..."
    default = "test"
}