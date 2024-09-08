terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }

  required_version = ">= 0.13"
}

provider "yandex" {
  token = var.yc_iam_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}
