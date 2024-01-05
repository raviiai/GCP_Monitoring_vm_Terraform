###########################################
## Random String Generator
###########################################

resource "random_string" "myrand_string" {
    count = 2
  length  = 5
  upper   = false
  special = false
}

################################################
## Firewall
################################################

# resource "google_compute_firewall" "allow_http" {
#     source_service_accounts = 
#   name    = "allow-http-rule"
#   network = "default"
#   allow {
#     ports    = ["80"]
#     protocol = "tcp"
#   }
#   target_tags = ["allow-http"]
#   priority    = 1000

# }

###########################################
## Google cloud compute instance
###########################################

resource "google_compute_instance" "this" {
  count        = 2
  name         = format("%s-%s",var.instance_name, random_string.myrand_string[count.index].id)
  machine_type = "e2-small"
  zone         = var.zone

    tags = ["allow-http"]
  network_interface {
    network = "default"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  
}


################################################
## Google Monitoring Dashboard
################################################

resource "google_monitoring_dashboard" "dashboard" {
    project = var.project_id
  dashboard_json = <<EOF
{
  "displayName": "My DashBoard VM",
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "CPU Utilization",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "metric.type=\"agent.googleapis.com/nginx/connections/accepted_count\"",
                "aggregation": {
                  "perSeriesAligner": "ALIGN_RATE"
                }
              },
              "unitOverride": "1"
            },
            "plotType": "LINE"
          }],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "text": {
          "content": "Widget 2",
          "format": "MARKDOWN"
        }
      },
      {
        "title": "Widget 3",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "metric.type=\"agent.googleapis.com/nginx/connections/accepted_count\"",
                "aggregation": {
                  "perSeriesAligner": "ALIGN_RATE"
                }
              },
              "unitOverride": "1"
            },
            "plotType": "STACKED_BAR"
          }],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      }
    ]
  }
}

EOF
}
############################################################
## Creating Alert Policy
############################################################

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "CPU Utilization > 50%"
  
  combiner     = "OR"
  conditions {
    display_name = "Condition 1"
    condition_threshold {
        comparison = "COMPARISON_GT"
        duration = "60s"
        filter = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
        threshold_value = "0.5"
        trigger {
          count = "1"
        }
    }
  }

  alert_strategy {
    notification_channel_strategy {
        renotify_interval = "1800s"
        notification_channel_names = [google_monitoring_notification_channel.email.name]
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  user_labels = {
    severity = "warning"
  }
}

#############################################
## Notification Channel
#############################################

resource "google_monitoring_notification_channel" "email" {
 display_name = "Tier 1 Support Email"
   type = "email"
   labels = {
     email_address = var.email
   }
 }