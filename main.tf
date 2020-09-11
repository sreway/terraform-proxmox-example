provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://${var.pm_ip}:8006/api2/json"
  pm_user = var.pm_user
  pm_password = var.pm_password
  pm_timeout = var.pm_timeout
  pm_parallel = var.pm_parallel
}

resource "proxmox_vm_qemu" "example" {
  count = length(var.vms_data)
  name = var.vms_data[count.index]["name"]
  target_node = var.vms_data[count.index]["target_node"]
  os_type = var.vms_data[count.index]["os_type"]
  clone = var.vms_data[count.index]["clone"]
  cores = var.vms_data[count.index]["cores"]
  sockets = var.vms_data[count.index]["sockets"]
  memory = var.vms_data[count.index]["memory"]
  scsihw = var.vms_data[count.index]["scsihw"]
  bootdisk = var.vms_data[count.index]["bootdisk"]

  dynamic "disk" {
    for_each = [for disk in var.vms_data[count.index]["disks"]:{
      id = disk.id
      size = disk.size
      type = disk.type
      storage = disk.storage
      storage_type = disk.storage_type
    }]

    content {
      id = disk.value.id
      size = disk.value.size
      type = disk.value.type
      storage = disk.value.storage
      storage_type = disk.value.storage_type
    }
  }

  dynamic "network" {
    for_each = [for network in var.vms_data[count.index]["networks"]:{
      id = network.id
      model = network.model
      bridge = network.bridge
    }]

    content {
      id = network.value.id
      model = network.value.model
      bridge = network.value.bridge
    }
  }
  nameserver = join(" ", var.vms_data[count.index]["nameservers"])
  ipconfig0 = tostring(try(var.vms_data[count.index]["networks"][0]["ci_network"], null))
  ipconfig1 = tostring(try(var.vms_data[count.index]["networks"][1]["ci_network"], null))
  ipconfig2 = tostring(try(var.vms_data[count.index]["networks"][2]["ci_network"], null))

  sshkeys = <<EOF
    ${var.ssh_keys}
  EOF

  ciuser = var.ci_user
  cipassword = var.ci_password

  lifecycle { ignore_changes = [network, cipassword] }

}

locals {
  vms = proxmox_vm_qemu.example.*
  inventory = templatefile("${path.module}/templates/inventory.tpl", {
    vms = local.vms
    ciuser = var.ci_user
  })
}

resource "local_file" "inventory" {
  content  = local.inventory
  filename = "${path.module}/inventory/example.yml"
}

resource "null_resource" "deploy_inventory" {
  triggers = {
    content = local_file.inventory.content
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${local_file.inventory.filename} site.yml"
  }
  depends_on = [local_file.inventory, proxmox_vm_qemu.example]
}
