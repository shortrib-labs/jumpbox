locals {
  directories = {
    "source"   = "${var.project_root}/src"
    "work"   = "${var.project_root}/work"
    "export" = "${var.project_root}/work/${var.vm_name}"
  }
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

  export {
    output_directory = local.directories.export

    force  = true
    images = false
  }
}

build {
  sources = ["source.vsphere-iso.outsystems-image"]

  post-processor "shell-local" {
    inline = [ 
      "sed -i '/<.vmw:BootOrderSection>/ r ${local.directories.source}/xml/product.xml' ${local.directories.export}/jumpbox-image.ovf"
    ] 
    only_on = [ "linux" ]
  }

  post-processor "shell-local" {
    inline = [ 
      "sed -i .bak '/<.vmw:BootOrderSection>/ r ${local.directories.source}/xml/product.xml' ${local.directories.export}/jumpbox-image.ovf"
    ] 
    only_on = [ "darwin" ]
  }

  post-processor "shell-local" {
    inline = [ 
      "( cd ${local.directories.export} && openssl sha512 -out jumpbox-image.mf jumpbox-image*.{ovf,vmdk})",
      "ovftool ${local.directories.export}/jumpbox-image.ovf ${local.directories.work}/jumpbox-image.ova",
    ] 
  }
}
