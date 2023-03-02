output "endpoint" {
    value = aws_db_instance.rds_instance.address
}

output "arn" {
    value = aws_db_instance.rds_instance.arn
}

output "rds_id" {
    value = aws_db_instance.rds_instance.id
}