output "hosts" {
  value = <<EOT
  %{ for vm in proxmox_vm_qemu.example.* }
  ${vm.name}: ssh ${var.ci_user}@${vm.ssh_host}
  %{ endfor }
  EOT
  description = "SSH hosts"
}