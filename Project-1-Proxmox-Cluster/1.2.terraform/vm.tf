resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  for_each  = { for s in var.servers : s.name => s }
  name      = each.value.name
  node_name = each.value.node_name

  initialization {
    datastore_id = "local"

    ip_config {
      ipv4 {
        address = each.value.ipv4_address
        gateway = each.value.ipv4_gateway
      }
      ipv6 {
        address = each.value.ipv6_address
        gateway = each.value.ipv6_gateway
      }
    }

    user_account {
      username = "ubuntu"
      keys = [chomp(file("~/.ssh/id_rsa.pub"))]
    }
  }

  disk {
    datastore_id = "local"
    file_id = "local:import/noble-minimal-cloudimg-amd64.qcow2"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 25
  }

  network_device {
    bridge = "lan"
    mtu    = 1450
  }

  cpu {
    cores = each.value.cpu_core
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }
}