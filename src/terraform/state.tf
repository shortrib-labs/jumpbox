terraform {
  backend "gcs" {
    bucket = "terraform-state-jumpbox"
    prefix = "terraform/state"
  }
}
