locals {
  directories = {
    "source"   = "${var.project_root}/src"
    "work"   = "${var.project_root}/work"
    "export" = "${var.project_root}/work/${var.vm_name}"
  }
}

source "vsphere-clone" "jumpbox-template" {
  vm_name   = var.vm_name
  template  = var.base_template

  CPUs                 = var.numvcpus
  RAM                  = var.memsize
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = var.disk_size
    disk_thin_provisioned = true
  }
  network      = var.vsphere_network

  vapp {
     properties = {
        hostname  = var.vm_name
        password  = var.default_password
        user-data = base64encode(file("${var.project_root}/secrets/template/user-data"))
     }
   }

  ssh_username         = "ubuntu"
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "10m"
 
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_username
  password            = var.vsphere_password
  datacenter          = var.vsphere_datacenter
  cluster             = var.vsphere_cluster
  datastore           = var.vsphere_datastore

  content_library_destination {
    name    = var.vm_name
    library = var.vsphere_content_library
    ovf     = true
    destroy = true
  }
}

build {
  sources = ["source.vsphere-clone.jumpbox-template"]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "cloud-init analyze blame -i /var/log/cloud-init.log",
    ]
  }

  provisioner "shell" {
    scripts = [
      "${local.directories.source}/scripts/install-keybase.sh"
    ]
  }
}
