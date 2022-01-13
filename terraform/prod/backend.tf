terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "bucket-stage-state"
    region                      = "ru-central1"
    key                         = "state.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
