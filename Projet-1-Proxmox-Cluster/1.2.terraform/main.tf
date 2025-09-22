terraform {
    required_providers {
        proxmox = {
            source  = "bpg/proxmox"
            version = "0.83.2"
        }
    }
}

provider "proxmox" {
  ssh {
    agent    = true
    username = "root"
  }
}

data "local_file" "ssh_public_key" {
    filename = pathexpand("~/.ssh/id_rsa.pub")
}