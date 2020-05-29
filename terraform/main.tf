provider "google" {
  project = var.project_name
  region = var.region
  zone = var.zone
}

#----------------------------------------------------------------------------------------------
#  CLOUD SOURCE REPOSITORY
#      - Enable API
#      - Create Repository
#----------------------------------------------------------------------------------------------

resource "google_project_service" "repo" {
  service = "sourcerepo.googleapis.com"
  disable_on_destroy = false
}

resource "google_sourcerepo_repository" "repo" {
  name = var.repository_name
  depends_on = [google_project_service.repo]
}

#----------------------------------------------------------------------------------------------
#  CLOUD BUILD
#      - Enable API
#      - Create Build Trigger
#----------------------------------------------------------------------------------------------

resource "google_project_service" "build" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloudbuild_trigger" "cloud_build_trigger" {
  name = var.repository_name
  description = "Cloud Source Repository Trigger ${var.repository_name} (${var.branch_name})"
  trigger_template {
    repo_name = var.repository_name
    branch_name = var.branch_name
  }

  filename = "cloudbuild.yaml"
  substitutions = {
    _SERVICE_ACCOUNT_EMAIL = google_service_account.sa.email
    _SERVICE_NAME= var.service_name
    _REGION = var.region
  }

  depends_on = [google_project_service.build, google_sourcerepo_repository.repo]
}

#----------------------------------------------------------------------------------------------
#  CLOUD REGISTRY
#      - Enable API
#      - Create Repository
#----------------------------------------------------------------------------------------------

resource "google_project_service" "registry" {
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

#----------------------------------------------------------------------------------------------
#  CLOUD RUN
#      - Enable API
#      - Create Service
#      - Expose the service to the public
#----------------------------------------------------------------------------------------------

resource "google_project_service" "run" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "my-service" {
  name = var.service_name
  location = var.region

  template  {
    spec {
    containers {
            image = "gcr.io/cloudrun/hello"
    }
  }
  }
  depends_on = [google_project_service.run]
}

resource "google_cloud_run_service_iam_member" "allUsers" {
  service  = google_cloud_run_service.my-service.name
  location = google_cloud_run_service.my-service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}


#----------------------------------------------------------------------------------------------
#  Creating Service Account
#   - Enable API
#   - Create SA
#----------------------------------------------------------------------------------------------

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "sa" {
  account_id = var.service_account_name
  display_name = "A Service Account email to access Google Sheet"
  depends_on = [google_project_service.iam]
}


#----------------------------------------------------------------------------------------------
#  Grant Cloud Build Permission
#----------------------------------------------------------------------------------------------

data "google_project" "project" {
}

resource "google_project_iam_binding" "binding" {
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role = "roles/run.admin"
  depends_on = [google_project_service.build]
}

resource "google_project_iam_binding" "sa" {
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role = "roles/iam.serviceAccountUser"
  depends_on = [google_project_service.build]
}


#----------------------------------------------------------------------------------------------
#  Enabling APIs for Sheet and Drive
#----------------------------------------------------------------------------------------------

resource "google_project_service" "sheet" {
  service = "sheets.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "drive" {
  service = "drive.googleapis.com"
  disable_on_destroy = false
}


#----------------------------------------------------------------------------------------------
#  Creating Local for image name
#----------------------------------------------------------------------------------------------

locals {
  image_name = var.image_name == "" ? "${var.region}/gcr.io/${var.project_name}/${var.service_name}": var.image_name
}