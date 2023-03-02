data "aws_vpc" "voltron_core" {

    filter {
      name   = "tag:Name"
      values = ["voltron-core"]
    }
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

data "template_file" "userdata" {
    template = file("userdata.sh")
}

locals {
    ids_sorted_by_az   = "${values(zipmap(data.aws_subnet.avail_subnet.*.availability_zone, data.aws_subnet.avail_subnet.*.id))}"
    cidr_sorted_by_az  = "${values(zipmap(data.aws_subnet.avail_subnet.*.availability_zone, data.aws_subnet.avail_subnet.*.cidr_block))}"
}

module "database" {
    source = "../modules/rds_postgres"

    db_port                        = var.db_port
    db_type                        = var.db_type
    db_version                     = var.db_version
    db_class                       = var.db_class
    db_name                        = var.db_name
    multi_az                       = var.multi_az
    app_name                       = var.app_name
    env                            = var.env
    vpc_id                         = data.aws_vpc.voltron_core.id
#    db_instance_snapshot_identifier = var.db_instance_snapshot_identifier != "" ? var.db_instance_snapshot_identifier : "${var.app_name}-${var.env}-db"
    db_instance_snapshot_identifier = var.db_instance_snapshot_identifier != "" ? var.db_instance_snapshot_identifier : "${var.app_name}"
}

module "ebs_volume" {
    source = "../modules/storage"

    az                             = var.az
    ebs_size                       = var.ebs_size
    vol_type                       = var.vol_type
    app_name                       = var.app_name
    env                            = var.env
}

module "ec2_instance" {
    source = "../modules/ec2_instance"

    instance_type                  = var.instance_type
    data_volume_id                 = module.ebs_volume.data_volume_id
    ssh_keys                       = lookup(var.ssh_keys, var.env)
    subnet_id                      = local.ids_sorted_by_az[0]
    vpc_id                         = data.aws_vpc.voltron_core.id
    app_name                       = var.app_name
    app_version                    = var.app_version
    env                            = var.env
    user_data                      = data.template_file.userdata.rendered
    app_conf                       = var.playbook1
    sys_conf                       = var.playbook2
    ebs_conf                       = var.playbook3
    db_dependency                  = module.database.rds_id
}

module "local_balancer" {
    source = "../modules/load_balancer"

    private_subnets                = data.aws_subnet.avail_subnet.*.id
    ec2_instance_id                = module.ec2_instance.host_id
    acm_san                        = var.acm_san
    vpc_id                         = data.aws_vpc.voltron_core.id
    app_port                       = var.app_port
    lb_port                        = var.lb_port
    app_name                       = var.app_name
    env                            = var.env
}

module "monitoring" {
    source = "../modules/monitoring"

    app_name                       = var.app_name
    env                            = var.env
    app_version                    = var.app_version
}

# -------------------------------------------------------
# Manages tfstate storage
# -------------------------------------------------------
terraform {
    required_version = "~> 1.0"
    backend "consul" {
        address = "consul.aws.sworks.com"
        scheme  = "https"
        lock    = true
        path    = "voltron/voltron-prod/us-east-1/voltron-sonarqube-prod/terraform_state"
    }
}