locals {
  directories = {
    "source"   = "${var.project_root}/src"
    "work"   = "${var.project_root}/work"
    "export" = "${var.project_root}/work/${var.vm_name}"
  }
}

source "vsphere-clone" "jumpbox-template" {
  vm_name   = var.vm_name

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
        user-data = base64encode(var.user_data)
     }
   }

  /*
  boot_command     = [
    "<esc><esc><esc>",
    "<enter><wait>",
    "/casper/vmlinuz ",
    "root=/dev/sr0 ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]
  boot_wait        = var.boot_wait
  shutdown_command = "sudo shutdown -P now"
  http_directory   = "${var.project_root}/secrets/template"
  */
  ssh_username         = "ubuntu"
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "10m"
 
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_username
  password            = var.vsphere_password
  datacenter          = var.vsphere_datacenter
  cluster             = var.vsphere_cluster
  datastore           = var.vsphere_datastore

  export {
    name  = var.vm_name
    images = false
    force = true

    output_directory = var.output_directory
  }
  
}

build {
  sources = ["source.vsphere-clone.jumpbox-template"]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "cloud-init analyze blame -i /var/log/cloud-init.log",
      "echo before",
      "find /var/lib/cloud -ls",
      "sudo cloud-init clean",
      "sudo cloud-init clean -l",
      "echo after",
      "find /var/lib/cloud -ls",
      "apt list --installed",
      "snap list"
    ]
  }

  provisioner "shell" {
    scripts = [
      "${local.directories.source}/scripts/install-keybase.sh"
    ]
  }
}
