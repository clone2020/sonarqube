terraform {
  required_providers {
    datadog = {
        source = "DataDog/datadog"
        version = "3.10.0"
    }
  }
}

provider "datadog" {
    api_key = "ffasdfas23452345asdfasdf345qsrasftrq"
    app_key = "casefqwrqdfaw45wre6t234dsr523twe54erg345wer562"
}

locals {
    datadog_tags = [
        "env:${var.env}",
        "service:${var.app_name}",
        "version:${var.app_version}"
    ]
}

variable "env" {}
variable "app_name" {}
variable "app_version" {}

resource "datadog_monitor" "ec2_host_ok" {
    type                = "metric alert"
    tags                = local.datadog_tags
    notify_no_data      = true
    include_tags        = true
    new_group_delay     = 300
    no_data_timeframe   = 30
    require_full_window = false
    query               = "min(last_10m):min:aws.ec2.host_ok{name:${var.app_name}-${var.env}} by {host} < 1"
    name                = "${var.app_name}-${var.env} AWS EC2 health check on {{host.name}}"

    monitor_thresholds {
        critical = 1
    }

    message = <<EOT
{{#is_laert}}
The EC2 health check has failed on {{host.name}}. The autoscaling group should replace the node but you should check the cluster health to ensure there are no other issues.
{{/is_alert}}

{{#is_recovery}}
The EC2 health check has recovered on {{host.name}}.
{{/is_recovery}}

@teams-volsup-sonarqube-alerts
EOT
}

resource "datadog_monitoring" "ec2_disk_space_used" {
    type                    = "metric alert"
    tags                    = local.datadog_tags
    include_tags            = false
    require_full_window     = false
    notify_no_data          = true
    no_data_timeframe       = 20
    new_group_delay         = 60
    query                   = "avg(last_5m):( avg:system.disk.used{name:${var.app_name}-${var.env}} by {host,device} / avg:system.disk.total{name:${var.app_name}-${var.env}} by {host,device} ) * 100 >= 85"
    name                    = "${var.app_name}-${var.env} - Free storage space for {{device.name}} on {{host.name}}"

    monitor_thresholds {
        critical = 85
    }

    message = <<EOT
{{#is_alert}}
Device {{device.name}} on host {{host.name}} is running low on free disk space. Normally, this should never happen for this particular service. Please login and check /opt/mattermost/logs and /var/logs/ to ensure logrotation is working. If those are clean, you will need to look elsewhere for the problem.
{{/is_alert}}

{{#is_recovery}}
Device {{device.name}} on {{host.name}} is no longer running low on free disk space.
{{/is_recovery}}

@teams-volsup-sonarqube-alerts
EOT
}

resource "datadog_monitor" "free_system_memory" {
    type                 = "metric alert"
    tags                 = local.datadog_tags
    include_tags         = false
    require_full_window  = false
    notify_no_data       = true
    no_data_timeframe    = 20
    new_group_delay      = 60
    query                = "avg(last_5m):sum:system.mem.pct_usable{name:${var.app_name}-${var.env}} by {host} <= 0.2"
    name                 = "${var.app_name}-${var.env} - Free system memory on {{host.name}}"

    monitor_thresholds {
        critical = 0.2
    }

    message = <<EOT
{{#is_alert}}
Free system on {{host.name}} has dropped below the threshold. If no other monitors are firing for Mattermost then either the hosts are not big enough or something else is utilizing too much memory.
{{/is_alert}}

{{#is_recovery}}
Free system memory on {{host.name}} has recovered.
{{/is_recovery}}

@teams-volsup-sonarqube-alerts
EOT
}