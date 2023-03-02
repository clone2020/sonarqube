output "subnet_cidr_blocks" {
    value = data.aws_subnet.avail_subnet.*.id
}

output "DB_Endpoint" {
    value = module.database.endpoint
}

output "DB_ARN" {
    value = module.database.arn
}

output "DB_id" {
    value = module.database.rds_id
}

output "LB_Name" {
    value = module.local_balancer.lb_DNSname
}

output "Cert_ARN" {
    value = module.local_balancer.cert_arn
}

output "HostIP" {
    value = module.ec2_instance.host_ip
}

output "Host_id" {
    value = module.ec2_instance.host_id
}

output "EBS_Volid" {
    value = module.ebs_volume.data_volume_id
}