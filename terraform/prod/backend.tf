terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "bucket-stage-state"
    region                      = "ru-central1"
    key                         = "state.tfstate"
    access_key                  = "WJ-3213oH-SvJpvkMG9i"
    secret_key                  = "Tc3Fvj321-m8RsmZT5hoIynGfM0xgfnB_Ix3od13"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
