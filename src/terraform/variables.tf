variable "project_root" {
  type = string
}

variable "domain" {
  type = string
}

variable "hashed_password" {
  type = string
}

variable "ssh_authorized_keys" {
  type = list
}

variable "cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 4096
}

variable "disk" {
  type    = number
  default = "81920"
}

variable "mac_address" {
  type = string
}

variable "ovf_path" {
  type = string
}


variable "vsphere_server" {
  type = string
}

variable "vsphere_username" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_host" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "vsphere_resource_pool" {
  type = string
}

variable "vsphere_folder" {
  type = string
}

locals {
  server_name    = "jumpbox.${var.domain}"
  vsphere_folder = "${var.vsphere_datacenter}/vm/${var.vsphere_folder}"
  directories = {
    work = "${var.project_root}/work"
  }
}
