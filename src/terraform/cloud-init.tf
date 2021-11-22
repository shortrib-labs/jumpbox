data "http" "microsoft_key" {
  url = "https://packages.microsoft.com/keys/microsoft.asc"
}

data "http" "microsoft_list" {
  url = "https://packages.microsoft.com/config/ubuntu/20.04/prod.list"
}

data "carvel_ytt" "user_data" {
  files = [
    "${var.project_root}/src/cloud-init/instance"
  ]
  values = {
    "domain" = var.domain

    "microsoft.pgp_key"    = data.http.microsoft_key.body,
    "microsoft.repository"  = data.http.microsoft_list.body,

    "ssh.authorized_keys.crdant" = var.ssh_public_key
  }

  ignore_unknown_comments = true
}


