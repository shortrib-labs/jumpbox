locals {
  directories = {
    "source"   = "${var.project_root}/src"
    "work"   = "${var.project_root}/work"
    "export" = "${var.project_root}/work/${var.vm_name}"
  }
  cloud_config = {
    "/meta-data" = ""
    "/user-data" = var.user_data
  }
}

source "vsphere-iso" "jumpbox-template" {
  vm_name   = var.vm_name

  iso_url      = var.image
   iso_checksum = var.image_checksum

  firmware      = "efi-secure"
  guest_os_type = "ubuntu64Guest"
  
  CPUs                 = var.numvcpus
  RAM                  = var.memsize
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = var.disk_size
    disk_thin_provisioned = true
  }
  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }

  cd_content   = local.cloud_config
  cd_label     = "cidata"

  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  boot_wait        = var.boot_wait
  shutdown_command = "echo '${var.default_password}' | sudo -S -E shutdown -P now"

  ssh_username         = "arceus"
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
  sources = ["source.vsphere-iso.jumpbox-template"]

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
