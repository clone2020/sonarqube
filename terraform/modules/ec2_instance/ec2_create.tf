
data "vault_generic_secret" "keypair" {
    path = "volsup-project/keypair/${var.env}"
}

data "vault_generic_secret" "rds_password" {
    path = "volsup-project/${var.app_name}/lab_rds"
}

data "vault_generic_secret" "secret-key" {
    path = "volsup-project/${var.app_name}/encryption"
}

data "aws_ami" "centos"{
    owners = ["self"]
    most_recent = true

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "tag:Name"
        values = ["Sonarqube Centos7 Packer AMI*"]
    }
    ### "name" is "AMI Name" in aws consle
    filter {
        name = "name"
        values = ["packer_AWS*"]
    }

}

resource "aws_instance" "my-app" {
    ami              = data.aws_ami.centos.image_id
    instance_type    = var.instance_type
    # The name of our SSH keypair we created above.
    key_name         = var.ssh_keys
    subnet_id        = var.subnet_id
    # Our Security group to allow HTTP and SSH access
    vpc_security_group_ids = [aws_security_group.allow_sg_sonar.id]

/*  provisioner "remote-exec" {
    inline = ["echo 'Wait untill SSH is ready'"]

    connection {
        type = "ssh"
        user = "centos"
        private_key = local_sensitive_file.private_key.content
        host = aws_instance.my-app.private_ip
    }
} 

    provisioner "local-exec" {
        command = "ansible-playbook -i ${aws_instance.y-app.private_ip}, ${var.userdata} --private-key ${local_sensitive_file.private_key.filename}"
    }

*/

    lifecycle {
        create_before_destroy = true
        prevent_destroy       = false
        ignore_changes        = [tags]
    }

    root_block_device {
      encrypted = true
    }

    user_data = var.user_data

    depends_on = [var.data_volume_id, ]
}

resource "aws_volume_attachment" "ebs_attach" {
    device_name    = "/dev/xvdf"
    volume_id      = var.data_volume_id
    instance_id    = aws_instance.my-app.id
    force_detach   = true
    skip_destroy   = false
}

resource "local_sensitive_file" "private_key" {
    content = data.vault_generic_secret.keypair.data["${var.ssh_keys}.pem"]
    filename = "${var.ssh_keys}.pem"
}

resource "local_sensitive_file" "secret_key" {
    content = data.vault_generic_secret.secret-key.data["${var.secret_key}"]
    filename = "${var.secret_key}"
}

resource "local_sensitive_file" "tf_ansible_vars_file_new" {
    content = <<-DOC
      # Ansible vars_file containing variable values from Terraform.
      # Generated by Terraform mgmt configuration.

      tf_secret_key: ${local_sensitive_file.secret_key.content}
      tf_secret_key_file: ${local_sensitive_file.secret_key.filename}
      tf_dppassword: ${data.vault_generic_secret.rds_password.data["main_password"]}
      tf_sonar_version: ${var.app_version}
      tf_env: ${var.env}
      tf_domain: ${lookup(var.domain, var.env)}
      DOC
    filename = "./tf_ansible_vars_file.yml"
}

resource "null_resource" "app_conf" {

    connection {
      type = "ssh"
      user = "centos"
      private_key = local_sensitive_file.private_key.content
      host = aws_instance.my-app.private_ip
    }

/*
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOT
      exec "sleep 2m"
      exec "ansible-playbook -i ${aws_instance.my-app.private_ip}, ${var.ebs_conf} --private-key ${local_sensitive_file.private_key.filename}"
      exec "rm -rf sonar-secret tf_ansible_vars_file.yml"
    EOT
  }
*/

    triggers = {
        instance_id = aws_instance.my-app.image_id
        command = "ansible-playbook -i ${aws_instance.my-app.private_ip}, ${var.app_conf} --private-key ${local_sensitive_file.private_key.filename}"
    }

    provisioner "local-exec" {
        interpreter = [
          "/bin/bash" ,"-c"
        ]
        command = "sleep 1m && ansible-playbook -i ${aws_instance.my-app.private_ip}, ${var.app_conf} --private-key ${local_sensitive_file.private_key.filename}"
    }

    depends_on = [
        aws_instance.my-app, null_resource.ebs_conf, aws_volume_attachment.ebs_attach, 
    ]
}

resource "null_resource" "ebs_conf" {

    connection {
      type = "ssh"
      user = "centos"
      private_key = local_sensitive_file.private_key.content
      host = aws_instance.my-app.private_ip
    }

    provisioner "local-exec" {
        interpreter = [
          "/bin/bash" ,"-c"
        ]
        command = "sleep 1m && ansible-playbook -i ${aws_instance.my-app.private_ip}, ${var.ebs_conf} --private-key ${local_sensitive_file.private_key.filename}"
    }

    depends_on = [
      aws_volume_attachment.ebs_attach, 
    ]

}

resource "null_resource" "os_conf" {

    connection {
      type = "ssh"
      user = "centos"
      private_key = local_sensitive_file.private_key.content
      host = aws_instance.my-app.private_ip
    }

    triggers = {
      instance_id = aws_instance.my-app.id
      command = "ansible-playbook -i ${aws_instance.my-app.private_ip}, ${var.sys_conf} --private-key ${local_sensitive_file.private_key.filename}"
    }

    provisioner "local-exec" {
        command = "ansible-playbook -i ${aws_instance.my-app.private-ip}, ${var.sys_conf} --private-key ${local_sensitive_file.private_key.filename}"
    }

    provisioner "local-exec" {
        command = "rm -rf lab_key.pem tf_ansible_vars_file.yml sonar-secret"
    }

    depends_on = [
      aws_volume_attachment.ebs_attach,
      null_resource.app_conf,
      aws_instance.my-app,
      var.db_dependency,
    ]
  
}