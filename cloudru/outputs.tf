# Terraform-конфигурация этого файла описывает часть облачной инфраструктуры.


output "vm_public_ip" {
  description = "Публичный IP-адрес ВМ"
  value       = cloudru_evolution_compute_interface.vm_interface.external_ip.ip_address
}

output "vm_private_ip" {
  description = "Приватный IP-адрес ВМ"
  value       = cloudru_evolution_compute_interface.vm_interface.ip_address
}

output "vm_id" {
  description = "ID ВМ"
  value       = cloudru_evolution_compute_vm.vm.id
}

