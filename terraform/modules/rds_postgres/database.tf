data "vault_generic_secret" "rds_password" {
    path = "volsup-project/${var.app_name}/lab_rds"
}

data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_kms_alias" "rds" {
    name = "alias/aws/rds"
}

data "aws_subnets" "private_subnet" {

    filter {
        name   = "tag:Name"
        values = ["core-private*us-east-1*"]
    }
}

data "aws_subnet" "avail_subnet" {
    count = length(data.aws_subnets.private_subnet.ids)
    id    = tolist(data.aws_subnets.private_subnet.ids)[count.index]
}

resource "aws_db_subnet_group" "sub_group" {
    name       = "sonar_subnet_group_${var.env}"
    subnet_ids = data.aws_subnet.avail_subnet.*.id
}

/*
data "aws_db_snapshot" "db_snapshot" {
    most_recent = true
    db_instance_identifier = var.db_instance_snapshot_identifier
}
*/

resource "aws_db_instance" "rds_instance" {
    allocated_storage                = 100 # gigabytes
    max_allocated_storage            = 1000
    backup_retention_period          = 7 # in days
    backup_window                    = "08:46-09:16"
    skip_final_snapshot              = true
    auto_minor_version_upgrade       = true
    copy_tags_to_snapshot            = true
    delete_automated_backups         = true
    deletion_protection              = false
    db_subnet_group_name             = aws_db_subnet_group.sub_group.id
    engine                           = var.db_type
    engine_version                   = var.db_version
    identifier                       = "${var.app_name}-${var.env}db"
    instance_class                   = var.db_class
    # snapshot_identifier             = "${data.aws_db_snapshot.db_snapshot.id}"
    # kms_key_id                      = data.aws_kms_alias.rds.arn
    maintenance_window               = "thu:04:18-thu:04:48"
    availability_zone                = (var.multi_az == "false" ? data.aws_availability_zones.available.names[0] : null)
    multi_az                         = var.multi_az
    db_name                          = var.db_name
    username                         = data.vault_generic_secret.rds_password.data["main_username"]
    password                         = data.vault_generic_secret.rds_password.data["main_password"]
    port                             = var.db_port
    publicly_accessible              = false
    storage_encrypted                = true # you should always do this
    storage_type                     = "gp2"
    vpc_security_group_ids           = [aws_security_group.sg_sonarqube_rds.id]

lifecycle {
    ignore_changes = [
        snapshot_identifier,
    ]
}

}

# -----------------------------------------------------------------
# Manages tfstate storage
# -----------------------------------------------------------------
/*
terraform {
    required_version = "~> 1.0.3"
    backend "consul" {
        address = "consul.aws.sworks.com"
        scheme  = "https"
        lock    = true
        path    = "voltron/voltron-lab/us-east-1/voltron-sonar-rds/terraform_state"  
    }
}
*/