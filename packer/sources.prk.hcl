packer {
    required_plugins {
        amazon = {
            version = ">= 0.0.1"
            source  = "github.com/hashicorp/amazon"
        }
    }
}

data "amazon-ami" "example" {
    filters = {
        virtualization-type = var.virtualization-type
        ena_support         = var.ena_support
        architechture       = var.architechture
        name                = var.name
        root-device-type    = var.root-device-type
    }
    owners        = ["amazon"]
    most_recent   = var.most_recent
}

source "amazon-ebs" "ssh-example" {
    ami_description = "${var.application_name} ${var.ami_desc}"
    ami_name        = "${var.application_name} ${var.ami_name}"
    instance_type   = var.instance_type
    encrypt_boot    = var.encrypt
    region          = var.aws_region
    source_ami      = data.amazon-ami.example.id
    ssh_username    = var.ssh_username
    communicator    = var.communicator
    vpc_id          = var.vpc_id
    subnet_id       = var.subnet_id

    launch_block_device_mappings {
        device_name            = "/dev/sda1"
        volume_size            = 10
        volume_type            = "gp3"
        encrypted              = true
        delete_on_termination  = true
        #kms_key_id            = "1234XX-asdg-zxcv-0987-04566lkjasdf"
    }

    tags = {
        Description           = "packer volsup {{timestamp}}"
        OS_Version            = "CentOS7 SWRX"
        Release               = "Latest"
        Base_AMI_ID           = "{{ .SourceAMI }}"
        Base_AMI_Name         = "{{ .SourceAMIName }}"
        Name                  = "${var.application_name} ${var.Name}"
        Environment           = var.env
        technical-contact     = var.technical_contact
        business-unit         = var.business-unit
        production            = var.production
        client-billable       = var.client-billable
    }
}