data "carvel_ytt" "user_data" {
  files = [
    "${var.project_root}/src/cloud-init/instance"
  ]
  values = {
    "domain" = var.domain
    "ssh.authorized_key" = var.ssh_public_key
    "hashed_password" = var.hashed_password
  }

  ignore_unknown_comments = true
}
