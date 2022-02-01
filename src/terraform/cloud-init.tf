data "carvel_ytt" "user_data" {
  files = [
    "${var.project_root}/src/cloud-init/instance"
  ]
  values = {
    "domain" = var.domain
    "ssh.authorized_key" = var.ssh_authorized_keys.0
    "hashed_password" = var.hashed_password
    "mac_address" = var.mac_address
    "ssh.user_authorized_keys" = var.user_authorized_keys
  }

  ignore_unknown_comments = true
}
