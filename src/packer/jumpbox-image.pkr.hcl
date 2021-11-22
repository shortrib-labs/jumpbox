variable "project_root" {
  type    = string
}

variable "boot_wait" {
  type    = string
  default = "2s"
}

variable "disk_size" {
  type    = string
  default = "81920"
}

variable "image" {
  type    = string
  default = "https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso"
}

variable "image_checksum" {
  type    = string
  default = "f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
}

variable "memsize" {
  type    = string
  default = "2048"
}

variable "numvcpus" {
  type    = string
  default = "2"
}

variable "vm_name" {
  type    = string
  default = "jumpbox-image"
}

variable "default_password" {
  type = string
}

variable "vsphere_username" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_server" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "vsphere_folder" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "output_directory" {
  type = string
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
  ssh_private_key_file = var.ssh_private_key_file
  // ssh_password         = var.default_password
  ssh_timeout          = "10m"

  vcenter_server      = var.vsphere_server
  username            = var.vsphere_username
  password            = var.vsphere_password
  datacenter          = var.vsphere_datacenter
  cluster             = var.vsphere_cluster
  datastore           = var.vsphere_datastore
  folder             = var.vsphere_folder

  convert_to_template = true
  export {
    output_directory = var.output_directory
  }
}

build {
  sources = ["source.vsphere-iso.outsystems-image"]
}
