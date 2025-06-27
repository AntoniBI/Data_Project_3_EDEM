resource "google_cloud_run_service" "flask_app" {
  name     = "flask-store"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/data-project-3/flask-store"
        env {
          name  = "AWS_ACCESS_KEY_ID"
          value = var.aws_access_key_id
        }
        env {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = var.aws_secret_access_key
        }
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_service.flask_app.location
  project  = var.gcp_project_id
  service  = google_cloud_run_service.flask_app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "cloud_run_url" {
  value = google_cloud_run_service.flask_app.status[0].url
}
