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

data "vsphere_folder" "folder" {
  path = local.vsphere_folder
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

resource "vsphere_virtual_machine" "vm" {
  name             = local.server_name
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
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
    label = "disk0"
    size  = var.disk

    io_share_count = 1000
  }

  cdrom {
    client_device = true
  }

  ovf_deploy {
    remote_ovf_url       = var.image
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "DHCP"

    allow_unverified_ssl_cert = true
  }

  vapp {
    properties = {
      "hostname"  = local.server_name
      "password"  = random_pet.default_password.id
      "user-data" = base64encode(local.user_data)
    }
  }
}

