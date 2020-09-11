---
example:
  hosts:
%{ for vm in vms ~}
    ${vm.ssh_host}:
      gather_facts: no
%{ endfor ~}
  vars:
    ansible_user: ${ciuser}
    ansible_python_interpreter: auto #future default in version 2.12
...