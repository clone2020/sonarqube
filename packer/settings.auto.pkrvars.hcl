ami_name       = "packer_AWS {{timestamp}}"
instance_type  = "t2.medium"
aws_region     = "us-east-1"
ssh_username   = "centos"
communicator   = "ssh"
env            = "prod"
vpc_id         = "vpc-0000abcd0000"
subnet_id      = "subnet-0000efgh0000ijkl"