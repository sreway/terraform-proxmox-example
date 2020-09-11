# Example usage Proxmox Terraform Provider

This repository contains examples Terraform and Ansible configurations to launch and set up Docker in QEMU Virtual Machine on [PVE](https://www.proxmox.com/en/proxmox-ve).

## Requirements

- [Terraform](https://www.terraform.io/) (*version 0.12 or later*)
- [Ansible](https://www.ansible.com/) (*version 2.8 or later*)
- [Go](https://golang.org/)

## Dependencies

- [ansible-role-docker](https://github.com/geerlingguy/ansible-role-docker.git)

## Providers

| Name | Version |
|------|---------|
| [local](https://registry.terraform.io/providers/hashicorp/local/latest/docs) | n/a |
| [null](https://registry.terraform.io/providers/hashicorp/null/latest/docs) | n/a |
| [proxmox](https://github.com/Telmate/terraform-provider-proxmox) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ci\_password | Default cloud-init password. | `string` | n/a | yes |
| ci\_user | Default cloud-init username. | `string` | n/a | yes |
| pm\_ip | Proxmox Managment IP address. | `string` | n/a | yes |
| pm\_parallel | Allowed simultaneous Proxmox processes. | `number` | `1` | no |
| pm\_password | Proxmox Managment Password. | `string` | n/a | yes |
| pm\_timeout | Timeout value (seconds) for Proxmox API calls. | `number` | `400` | no |
| pm\_user | Proxmox Managment User. | `string` | n/a | yes |
| ssh\_keys | SSH Public keys. | `string` | n/a | yes |
| vms\_data | List of Qemu Virtual Machine. | <pre>list(object({<br>    name = string<br>    target_node = string<br>    clone = string<br>    os_type = string<br>    cores = number<br>    sockets = number<br>    memory = number<br>    scsihw = string<br>    bootdisk = string<br><br>    disks = list(object({<br>      id = number<br>      size = string<br>      type = string<br>      storage = string<br>      storage_type = string<br>    }))<br><br>    networks = list(object({<br>      id = number<br>      model = string<br>      bridge = string<br>      ci_network = string<br>    }))<br><br>    nameservers = list(string)<br><br>  }))</pre> | <pre>[<br>  {<br>    "bootdisk": "scsi0",<br>    "clone": "centos-base-system",<br>    "cores": 4,<br>    "disks": [<br>      {<br>        "id": 0,<br>        "size": "40G",<br>        "storage": "local-lvm",<br>        "storage_type": "lvm",<br>        "type": "scsi"<br>      },<br>      {<br>        "id": 1,<br>        "size": "30G",<br>        "storage": "local-lvm",<br>        "storage_type": "lvm",<br>        "type": "scsi"<br>      }<br>    ],<br>    "memory": 2048,<br>    "name": "centos-7-testing",<br>    "nameservers": [<br>      "10.128.4.127",<br>      "192.168.13.27"<br>    ],<br>    "networks": [<br>      {<br>        "bridge": "vmbr0",<br>        "ci_network": "ip=192.168.10.192/24,gw=192.168.11.1",<br>        "id": 0,<br>        "model": "virtio"<br>      },<br>      {<br>        "bridge": "vmbr0",<br>        "ci_network": "ip=192.168.10.193/24,gw=192.168.11.1",<br>        "id": 1,<br>        "model": "virtio"<br>      }<br>    ],<br>    "os_type": "l26",<br>    "scsihw": "virtio-scsi-pci",<br>    "sockets": 1,<br>    "target_node": "pve"<br>  }<br>]</pre> | no |

>Terraform VM Qemu Resource: [doc](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/resource_vm_qemu.md)

## Outputs

| Name | Description |
|------|-------------|
| hosts | SSH hosts |

## Usage

- Clone this repo.

- Install Ansible role dependencies.

```bash
ansible-galaxy install -r requirements.yml -p ./roles
```

- Install Terraform Provider Proxmox

```bash
go get -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
go get -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
go install -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
go install -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
cp $GOPATH/bin/terraform-provider-proxmox ~/.terraform.d/plugins
cp $GOPATH/bin/terraform-provisioner-proxmox ~/.terraform.d/plugins
```

- Run terraform, it will create a QEMU virtual machines, inventory file ([example](inventory/example.yml)) and deploy environment:

```bash
terraform init
terraform plan -var-file=example.tfvars
terraform apply -var-file=example.tfvars
```
