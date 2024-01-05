output "instance_name_1" {
  value = google_compute_instance.this[0].name
}

output "instance_name_2" {
  value = google_compute_instance.this[1].name
}

output "dashboard_id" {
  value = google_monitoring_dashboard.dashboard.id
}