###########################################
## Random String Generator
###########################################

resource "random_string" "myrand_string" {
  count   = 2
  length  = 5
  upper   = false
  special = false
}

###########################################
## Google cloud compute instance
###########################################

resource "google_compute_instance" "this" {
  count        = 2
  name         = format("%s-%s", var.instance_name, random_string.myrand_string[count.index].id)
  machine_type = "e2-small"
  zone         = var.zone

  network_interface {
    network = "default"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # metadata = {
  #   "google-logging-enabled" = "true"
  #   "ops-agent-instructions" = "install"
  # }

}

################################################
## Installing OPs Agent
################################################

# module "cloud-operations_agent-policy" {
#   source  = "terraform-google-modules/cloud-operations/google//modules/agent-policy"
#   version = "0.4.0"
#   # insert the 4 required variables here
#   project_id = var.project_id
#   policy_id  = "ops-agents-policy"

#   agent_rules = [
#     {
#       type               = "ops-agent"
#       version            = "current-major"
#       package_state      = "installed"
#       enable_autoupgrade = true
#     },
#   ]

#   os_types = [
#     {
#       short_name = "debian"
#       version    = "11"
#     },
#   ]

# }

################################################
## Google Monitoring Dashboard
################################################

resource "google_monitoring_dashboard" "dashboard" {
  project        = var.project_id
  dashboard_json = file("${path.module}/dashboard.json")
}
############################################################
## Creating Alert Policy
############################################################

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "CPU Utilization > 30%"

  combiner = "OR"
  conditions {
    display_name = "Condition 1"
    condition_threshold {
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      threshold_value = "0.3"
      trigger {
        count = "1"
      }
    }
  }

  alert_strategy {
    notification_channel_strategy {
      renotify_interval          = "1800s"
      notification_channel_names = [google_monitoring_notification_channel.email.name]
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  user_labels = {
    severity = "warning"
  }
}
# comeent addwd

#############################################
## Notification Channel
#############################################

resource "google_monitoring_notification_channel" "email" {
  display_name = "Tier 1 Support Email"
  type         = "email"
  labels = {
    email_address = var.email
  }
}

## comment added
