output "host_ip" {
    value = aws_instance.my-app.private_ip
}

output "host_id" {
    value = aws_instance.my-app.id
}