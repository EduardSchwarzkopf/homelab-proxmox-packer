variable "proxmox_hostname" {
  type        = string
  description = "The FQDN or IP address of a Proxmox node. Only one node should be specified in a cluster."
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The token to login to the Proxmox node/cluster. The format is USER@REALM!TOKENID. (e.g. packer@pam!packer_pve_token)"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The secret for the API token used to login to the Proxmox API."
  sensitive   = true
}

variable "proxmox_insecure_connection" {
  description = "true/false to skip Proxmox TLS certificate checks."
  type        = bool
  default     = false
}

variable "proxmox_node" {
  type    = string
  description = "The name of the Proxmox node that Packer will build templates on."
  default= "pve"
}

variable "vm_os_version" {
  type        = string
  description = "The guest operating system version. Used for naming. (e.g. '24.04.2')"
}