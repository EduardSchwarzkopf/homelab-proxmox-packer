# Homelab Proxmox Packer Templates

This repository contains Packer configurations for building Proxmox VM templates using both cloud‑init and autoinstall approaches.

## ⚠️ Disclaimer

These Packer templates are provided **as-is** and are intended for **personal use only**. They have been tailored to my own Proxmox environment, storage pools, cloud-init configuration, ISO setup, and default settings.

If you choose to use or adapt these templates:

- You are **solely responsible** for reviewing and adjusting all configuration options, variable values, and provisioning scripts to match your own infrastructure.
- I offer **no warranties**, express or implied, including without limitation fitness for a particular purpose, performance, or compatibility.
- In no event shall the author be liable for any direct, indirect, incidental, or consequential damages arising from the use or misuse of these templates—even if advised of the possibility of such damage.

## Prerequisites

- **Packer** ≥ 1.12.0, including the official Proxmox plugin
- Proxmox VE cluster or single node (v6.x, 7.x or 8.x)
- ISO files uploaded to a Proxmox storage pool
- API token (ID and secret) with permissions to create and convert VMs to templates
- CD ISO creation command: e.g. xorriso: [deb](https://packages.debian.org/de/sid/otherosfs/xorriso) [arch](https://man.archlinux.org/man/xorriso.1.en)

## Setup & Build Guide

1. **Install & initialize Packer plugins:**

   ```bash
   packer init .
   ```

2. **Prepare variables:**
   Customize any example files (or your own file). 
   You can override via `-var-file=`, CLI `-var`, or environment (`PKR_VAR_*`).

3. **Build the template:**

   ```bash
   packer build -force -var-file=ubuntu-<os_version>.pkrvars.hcl .
   ```

   This will create a VM in Proxmox, perform an unattended installation via cloud-init, install any provisioning steps, and convert it to a template.

## Secrets & Version Control

- Do **not** commit `secrets.auto.pkrvars.hcl`. It’s in `.gitignore` and should hold sensitive variables such as API tokens.
- Use separate `.pkrvars.hcl` files for each OS/version, but only commit non-sensitive defaults.

## User Tokens & Permissions

Ensure your Proxmox API token has permissions to:

- Allocate VM, clone, convert to template
- Manage cloud-init CD-ROM
- Access storage pools

## Example Workflow

```bash
git clone https://github.com/yourusername/homelab-proxmox-packer.git
cd linux

packer init .
packer build -force -var-file=ubuntu-24402.pkrvars.hcl .
```

After the build completes, the new template will appear in your Proxmox GUI under `VM Templates`.

## References

- Credits: [proxmox-packer-templates](https://github.com/Pumba98/proxmox-packer-templates/tree/master) by @Pumba98
- Packer Proxmox ISO: https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso

