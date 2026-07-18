# Terraform-конфигурация этого файла описывает часть облачной инфраструктуры.


output "vm_public_ip" {
  description = "Публичный IP-адрес ВМ"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "vm_private_ip" {
  description = "Приватный IP-адрес ВМ"
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}
