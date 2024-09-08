variable "yc_token" {
  type      = string
  sensitive = true
}

variable "yc_cloud_id" {
  type      = string
  sensitive = true
}

variable "yc_folder_id" {
  type      = string
  sensitive = true
}

variable "datadog_api_key" {
  description = "88d00d4dbd2af4e9f7945f39ed267e06"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "5b747449f2d429fe0cddb4ffdef9efb2502a7dd4"
  type        = string
  sensitive   = true
}

variable "db_name" {
  type      = string
  sensitive = true
}

variable "db_user" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "yc_postgresql_version" {
  description = "The PostgreSQL version for the cluster"
  type        = string
  default     = "13"
}

