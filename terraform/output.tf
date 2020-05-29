output "project_id" {
  value = var.project_name
}

output "url" {
  value = "${google_cloud_run_service.my-service.status[0].url}"
}

output "google_service_account_email" {
  value = google_service_account.sa.email
}
