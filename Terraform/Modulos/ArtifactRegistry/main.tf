resource "google_service_account" "artifact_registry_sa" {
  account_id   = "artifact-registry-sa"
  display_name = "Artifact Registry Service Account"
  project      = "nice-gate-463112-m8"
}

resource "google_project_iam_member" "artifact_registry_sa_member" {
  project = "nice-gate-463112-m8"
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.artifact_registry_sa.email}"
}

resource "google_artifact_registry_repository" "central_repo" {
  project       = "nice-gate-463112-m8"
  location      = "europe-southwest1"
  repository_id = "data-project-3"
  description   = "Repository for data project"
  format        = "DOCKER"
}