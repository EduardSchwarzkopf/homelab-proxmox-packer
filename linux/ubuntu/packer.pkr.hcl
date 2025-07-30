packer {
  required_version = ">= 1.12.0"
  required_plugins {
    proxmox = {
      version = "= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  build_by             = "Built by: HashiCorp Packer ${packer.version}"
  os_name              = "ubuntu"
  build_username       = local.os_name
  timestamp            = timestamp()
  build_date           = formatdate("DD-MM-YYYY hh:mm ZZZ", local.timestamp)
  build_version        = formatdate("YYYYMMDD", local.timestamp)
  build_description    = "Version: ${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
  formatted_os_version = replace(var.vm_os_version, ".", "-")
  os_family            = "linux"
  vm_name              = "${local.os_family}-${local.os_name}-${local.formatted_os_version}"

  iso_checksums = {
    "24.04.2" = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  }

  iso_checksum = lookup(local.iso_checksums, var.vm_os_version, "sha256:UNKNOWN")
  os_type      = "l26"
}

source "proxmox-iso" "ubuntu" {

  // Proxmox Connection Settings and Credentials
  proxmox_url              = "https://${var.proxmox_hostname}/api2/json"
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = var.proxmox_insecure_connection

  // Proxmox Settings
  node = var.proxmox_node

  // Virtual Machine Settings
  vm_name         = local.vm_name
  tags            = "template;${local.os_family};${local.os_name}_${replace(var.vm_os_version, ".", "")}"
  sockets         = 1
  cores           = 2
  cpu_type        = "kvm64"
  memory          = 2048
  os              = local.os_type
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = "8G"
    type         = "scsi"
    storage_pool = "local-lvm"
    format       = "raw"
  }

  qemu_agent = true

  ssh_username = local.build_username
  ssh_password = local.build_username
  ssh_port     = 22
  ssh_timeout  = "5m"

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  // Boot and Provisioning Settings
  boot_wait = "5s"
  boot      = "order=scsi0;net0;ide0"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall quiet ds=nocloud",
    "<f10><wait>",
    "<wait1m>",
    "yes<enter>"
  ]

  boot_iso {
    type              = "ide"
    iso_file          = "local:iso/ubuntu-${var.vm_os_version}-live-server-amd64.iso"
    unmount           = true
    iso_checksum      = local.iso_checksum
    keep_cdrom_device = false
  }

  additional_iso_files {
    type              = "ide"
    index             = 1
    iso_storage_pool  = "local"
    unmount           = true
    keep_cdrom_device = false
    cd_files = [
      "${path.cwd}/http/meta-data",
      "${path.cwd}/http/user-data"
    ]
    cd_label = "cidata"
  }


  template_name        = "${local.vm_name}-${local.build_version}"
  template_description = local.build_description

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

}

# Build Definition to create the VM Template
build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",
      "sudo cloud-init clean",
      "sudo rm /etc/cloud/cloud.cfg.d/*"
    ]
  }
}
