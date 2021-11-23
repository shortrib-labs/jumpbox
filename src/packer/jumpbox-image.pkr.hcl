locals {
  property_config = file("${var.project_root}/src/xml/product.xml")
}

source "vsphere-iso" "outsystems-image" {
  vm_name    = var.vm_name
  vm_version = "19"

  iso_url       = var.image
  iso_checksum  = var.image_checksum
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
  http_directory   = "${var.project_root}/secrets/image"

  ssh_username         = "ubuntu"
  ssh_password         = var.default_password
  ssh_timeout          = "10m"

  vcenter_server      = var.vsphere_server
  username            = var.vsphere_username
  password            = var.vsphere_password
  datacenter          = var.vsphere_datacenter
  cluster             = var.vsphere_cluster
  datastore           = var.vsphere_datastore

  configuration_parameters = {
    "property" = local.property_config
  }

  content_library_destination {
    name    = var.vm_name
    library = var.vsphere_content_library
    ovf     = true
    destroy = true
  }
}

build {
  sources = ["source.vsphere-iso.outsystems-image"]
}
