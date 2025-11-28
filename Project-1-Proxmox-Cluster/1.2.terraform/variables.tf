variable "pve_nodes" {
  description = "List of Proxmox nodes (preference order)"
  type        = list(string)
  default     = [
    "pve-node1",
    "pve-node2",
    "pve-node3",
  ]
}

variable "servers" {
  type = list(object({
    name          = string
    node_name     = string
    ipv4_address  = string
    ipv4_gateway  = string
    ipv6_address  = string
    ipv6_gateway  = string
    disk_size     = number
    cpu_core      = number
    memory        = number
  }))

  default = [
    { name = "k8s-master"
      node_name    = "pve-node1"
      ipv4_address = "192.168.100.10/24"
      ipv4_gateway = "192.168.100.1"
      ipv6_address = "fd00:100::10/64"
      ipv6_gateway = "fd00:100::1"
      disk_size    = 25
      cpu_core     = 2
      memory       = 1024
    },
    { name = "k8s-worker1"
      node_name    = "pve-node2"
      ipv4_address = "192.168.100.11/24"
      ipv4_gateway = "192.168.100.1"
      ipv6_address = "fd00:100::11/64"
      ipv6_gateway = "fd00:100::1"
      disk_size    = 25
      cpu_core     = 2
      memory       = 1024
    },
    { name = "k8s-worker2"
      node_name    = "pve-node3"
      ipv4_address = "192.168.100.12/24"
      ipv4_gateway = "192.168.100.1"
      ipv6_address = "fd00:100::12/64"
      ipv6_gateway = "fd00:100::1"
      disk_size    = 25
      cpu_core     = 2
      memory       = 1024
    },
  ]
}