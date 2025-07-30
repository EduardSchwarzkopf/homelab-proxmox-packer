packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.7"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  timestamp = timestamp()
}

source "proxmox-iso" "talos" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = var.proxmox_nodename
  insecure_skip_tls_verify = true
  iso_file                 = "local:iso/archlinux-x86_64.iso"

  # If you want to use a mirror directly, the below works nice. 
  # iso_url = "https://mirrors.dotsrc.org/archlinux/iso/2024.02.01/archlinux-x86_64.iso"
  # iso_checksum = "sha256:891ebab4661cedb0ae3b8fe15a906ae2ba22e284551dc293436d5247220933c5"
  # iso_storage_pool = "local"
  # iso_download_pve = true

  unmount_iso              = true
  os                   = "l26"
  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  disks {
    type         = "virtio"
    storage_pool = var.proxmox_storage
    format     = "qcow2"
    disk_size  = "20GB"
  }

  disks {
    type         = "virtio"
    storage_pool = var.proxmox_storage
    format     = "qcow2"
    disk_size  = "10GB"
  }

  memory       = 4096
  cpu_type     = "host"
  sockets      = 2
  cores        = 2
  tags         = "${var.talos_version};template"

  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout  = "15m"

  qemu_agent   = true

  template_name = "talos-template-${var.talos_version}-qemu"
  template_description = "${local.timestamp} - Talos ${var.talos_version} template" 

  boot_wait = "20s"
  boot_command = [
    "<enter><wait50s>",
    "passwd<enter><wait1s>packer<enter><wait1s>packer<enter>",
    "ip address add ${var.static_ip} broadcast + dev ens18<enter><wait>",
    "ip route add 0.0.0.0/0 via ${var.gateway} dev ens18<enter><wait>",
    "ip link set dev ens18 mtu 1300<enter>",
  ]
}