variable "project_name" {
   description = "The project ID where all resources will be launched."
  type = string
}

variable "region" {
  description = "The location region to deploy the Cloud Run services. Note: Be sure to pick a region that supports Cloud Run."
  type        = string
}

variable "zone" {
  description = "The location zone to deploy the Cloud Run services. Note: Be sure to pick a region that supports Cloud Run."
  type        = string
}

variable "gcr_region" {
  description = "Name of the GCP region where the GCR registry is located. e.g: 'us' or 'eu'."
  type        = string
}

variable "branch_name" {
    description = "Example branch name used to trigger builds."
    default = "master"
}

variable "service_name" {
  description = "The name of the Cloud Run service to deploy."
  type        = string
  default     = "config-service"
}

variable "repository_name" {
  description = "Name of the Google Cloud Source Repository to create."
  type        = string
  default     = "config-app"
}

variable "image_name" {
  description = "The name of the image to deploy. Defaults to a publically available image."
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

variable "service_account_name" {
  description = "The name of the Service Account."
  type        = string
  default     = "config-service"
}