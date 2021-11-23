variable "project_root" {
  type    = string
}

variable "boot_wait" {
  type    = string
  default = "5s"
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

variable "vsphere_content_library" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "output_directory" {
  type = string
}
