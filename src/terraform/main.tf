data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "random_pet" "default_password" {
  length = 4
}

locals {
  user_data = <<-DATA
  #cloud-config
  ${data.carvel_ytt.user_data.result}
  DATA
}

resource "vsphere_virtual_disk" "home" {
  size       = 50
  vmdk_path  = "fcd/jumpbox.${var.domain}-home.vmdk"
  datacenter = data.vsphere_datacenter.datacenter.name
  datastore  = data.vsphere_datastore.datastore.name
  type       = "thin"
}

resource "vsphere_virtual_machine" "jumpbox" {
  name             = local.server_name
  datacenter_id     = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vsphere_folder

  num_cpus = var.cpus
  memory   = var.memory
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id     = data.vsphere_network.network.id
    use_static_mac = true
    mac_address    = var.mac_address
  }

  disk {
    label            = "disk0"
    size             = var.disk
    unit_number      = 0

    thin_provisioned = true
  }

  disk {
    label        = "disk1"
    datastore_id = data.vsphere_datastore.datastore.id
    attach       = true
    path         = vsphere_virtual_disk.home.vmdk_path
    unit_number  = 1
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      "instance-id" = "id-ovf"
      "hostname"    = local.server_name
      "password"    = random_pet.default_password.id
      "user-data"   = base64encode(local.user_data)
    }
  }

  ovf_deploy {
    allow_unverified_ssl_cert = true        # deals with golang's ssl madness
    local_ovf_path = var.ovf_path
    ip_protocol          = "IPV4"
    ip_allocation_policy = "DHCP"
    disk_provisioning    = "thin"
  }

  extra_config = {
    "isolation.tools.copy.disable"         = false
    "isolation.tools.paste.disable"        = false
    "isolation.tools.SetGUIOptions.enable" = true
  }
}

