data "aws_kms_alias" "ebs" {
    name = "alias/aws/ebs"
}

resource "aws_ebs_volume" "data-vol" {
    availability_zone = var.multi_az
    size              = var.ebs_size
    encrypted         = true
    type              = var.vol_type
#    kms_key_id        = data.aws_kms_alias.ebs.arn

    lifecycle {
      prevernt_destroy = false
    }
  
}

resource "aws_ebs_snapshot" "data_vol_snapshot" {
    volume_id    = aws_ebs_volume.data-vol.id
    description  = "${var.app_name}-${var.env} App Volume Snapshot"
  
}

##################### snapshot policy #######################

resource "aws_iam_role" "data_dlm_lifecycle_role" {
    name = "${var.app_name}-${var.env}_lm-lifecycle-role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10.17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "dlm.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ebs_dlm_lifecycle" {
    name = "${var.app_name}-${var.env}-dlm-lifecycle-policy"
    role = aws_iam_role.data_dlm_lifecycle_role.id

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:CreateSnapshots",
                "ec2:DeleteSnapshot",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*::snapshot/*
        }
    ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "ebs-policy" {
    description        = "${var.app_name}-${var.env} DLM lifecycle policy"
    execution_role_arn = aws_iam_role.data_dlm_lifecycle_role.arn
    state              = "ENABLED"

    policy_details {
        resource_types = ["VOLUME"]

        schedule {
            name = "2 weeks of daily snapshots"

            create_rule {
                interval      = 24
                interval_unit = "HOURS"
                times         = ["23:45"]
            }
            
            retain_rule {
                count = 14
            }

            tags_to_add = {
              "SnapshotCreator" = "DLM"
            }

            copy_tags = true
        }

        target_tags = {
          "Snapshot"  = "true"
          "Name"      = "${var.app_name}-${var.env} DLM lifecycle policy"
        }
    }
}
