variable "env" {
    description = "Environment"
    type        = string
    default     = "test"
}

variable "volsup_vault_approle_role_id" {}

variable "volsup_vault_approle_secret_id" {}

# Database variables.

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
    default = "db.t3.medium"
}

variable "db_name" {
    description = "Name of the DB"
    default     = "sonarqube-test-db"
}

variable "db_instance_snapshot_identifier" {
    description = "Name of the DB instance to find latest snapshot"
    type        = string
    default     = ""
}

# EBS variables.

variable "az" {
    description = "availabulity zone for EBS"
    type        = string
    default     = "us-east-1a"
}

variable "ebs_size" {
    description = "EBS size in Gb"
    type        = number
    default     = 100
}

variable "vol_type" {
    description = "ebs volume type"
    default     = "gp3"
}

# EC2 and Monitoring variables.

variable "app_version" {
    description = "application version to be changed in sonarqube.service, datadog.yaml and sonarqube.conf.yaml"
}

variable "instance_type" {
    description = "Instance type"
}

variable "playbook1" {
    description = "EBS and application configuration"
    default = "playbooks/app_conf.yaml"
}

variable "playbook2" {
    description = "System configuration"
    default = "playbooks/sys_conf.yaml"
}

variable "playbook3" {
    description = "ebs creation and configuration"
    default = "playbooks/ebs_conf.yaml"
}

# Load balancer and ACM route53 records variable.

variable "acm_san" {
    type = list(string)
    default = ["sonar.sworks.net", "sonar.internal.sworks.net", "sonarqube.aws.sworks.com", "sonar.aws.sworks.com"]
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

variable "ssh_keys" {
    type        = map
    description = "Private key for ssh access to ec2 instance."
    default     = {
        test = "lab_key"
        prod = "pen_key"
    }
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

######################### Resource tagging variables #########################

variable "applicaation_group" {
    description = "The name of the application group or service or project to which the resource belongs."
    default     = "voltron-sonarqube"
}

variable "technical_contact" {
    description = "The email distro of the responsible squad /team"
    default     = "volsup@sworks.com"
}

variable "business_unit" {
    description = "The Bushiness Unit associated with the resource. Used for cost allocation and tracking. e.g, Product Engineering"
    default     = "Product Engineering"
}

variable "app_name"{
    type = string
    default = "sonarqube"
}

variable "owner" {
    type = string
    default = "volsup@sworks.com"
}

variable "client_billable" {
    description = "Identity whether the reource is in production or not . The combination of Business Unit and this tag will enable accurate financial tracking."
    type        = bool
    default     = "false"
}

variable "production" {
    description = "Identity whether the resource is in production or not. The combination of Business Unit and this tag will enable accurate financial tracking."
    type        = bool
    default     = "false"
}
