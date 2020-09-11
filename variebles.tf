variable "pm_ip" {
  type = string
  description = "Proxmox Managment IP address."
}

variable "pm_user" {
  type = string
  description = "Proxmox Managment User."
}

variable "pm_password" {
  type = string
  description = "Proxmox Managment Password."
}

variable "pm_timeout" {
  type = number
  default = 400
  description = "Timeout value (seconds) for Proxmox API calls."
}

variable "pm_parallel" {
  type = number
  default = 1
  description = "Allowed simultaneous Proxmox processes."
}

variable "ci_user" {
  type = string
  description = "Default cloud-init username."
}

variable "ci_password" {
  type = string
  description = "Default cloud-init password."
}

variable "ssh_keys" {
  type = string
  description = "SSH Public keys."
}

variable "vms_data" {
  type = list(object({
    name = string
    target_node = string
    clone = string
    os_type = string
    cores = number
    sockets = number
    memory = number
    scsihw = string
    bootdisk = string

    disks = list(object({
      id = number
      size = string
      type = string
      storage = string
      storage_type = string
    }))

    networks = list(object({
      id = number
      model = string
      bridge = string
      ci_network = string
    }))

    nameservers = list(string)

  }))

  default = [

    {
      name = "centos-7-testing"
      target_node = "pve"
      clone = "centos-base-system"
      os_type = "l26"
      cores = 4
      sockets = 1
      memory = 2048
      scsihw = "virtio-scsi-pci"
      bootdisk = "scsi0"

      disks = [
        {
          id = 0
          size = "40G"
          type = "scsi"
          storage = "local-lvm"
          storage_type = "lvm"
        },
        {
          id = 1
          size = "30G"
          type = "scsi"
          storage = "local-lvm"
          storage_type = "lvm"
        },
      ]

      networks = [
        {
          id = 0
          model = "virtio"
          bridge = "vmbr0"
          ci_network = "ip=192.168.10.192/24,gw=192.168.11.1"
        },
        {
          id = 1
          model = "virtio"
          bridge = "vmbr0"
          ci_network = "ip=192.168.10.193/24,gw=192.168.11.1"
        }
      ]

      nameservers = ["10.128.4.127", "192.168.13.27"]
    },

  ]

  description = "List of Qemu Virtual Machine."
}
