output "vm_public_ip" {
  description = "Публичный IP-адрес ВМ"
  value       = cloudru_compute_floating_ip.vm_floating_ip.address
}

output "vm_private_ip" {
  description = "Приватный IP-адрес ВМ"
  value       = cloudru_compute_vm.vm.network_interface[0].ip_address
}

output "vm_id" {
  description = "ID ВМ"
  value       = cloudru_compute_vm.vm.id
}