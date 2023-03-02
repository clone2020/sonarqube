variable "vpc_id" {}

variable "hosted_zone_id" {
    type        = map
    description = "Publish Zone id in route 53"
    default     = {
        test = "Z2STIX312NJ9CJ"
        prod = "ZYGP0ZZBXVQDJ"
    }
}

variable "domain" {
    type        = map
    description = "Full domain of the databse."
    default     = {
        test = "aws-test.secure.com"
        prod = "aws.secure.com"
    }
}

variable "db_instance_snapshot_identifier" {
    description = "Name of the DB instance to find latest snapshot of"
    type        = string
    default     = ""
}

variable "app_name" {
    default = "sonarqube"
}

variable "env" {
    default = "test"
}

variable "db_port" {
    description = "Port of Postgresql DB"
    type        = number
    default     = 5432
}

variable "db_type" {
    description = "Type of DB used"
    type        = string
    default     = "postgres"
}

variable "multi_az" {
    description = "enhanced availability for database instances within a single AWS Region"
    type        = bool
    default     = true
}

variable "db_version" {
    description = "Postgres engine version"
    type        = number
    default     = 12.5
}

variable "db_class" {
    description = "The class of db instance"
    type        = string
    default     = "db.t3.medium"
}

variable "db_name" {
    description = "Name of the DB"
    default     = "sonarqube_test_db"
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
