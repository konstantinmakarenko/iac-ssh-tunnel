variable "auth_key_id" {
  description = "ID ключа сервисного аккаунта Cloud.ru"
  type        = string
  sensitive   = true
}

variable "auth_secret" {
  description = "Секрет сервисного аккаунта Cloud.ru"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "ID проекта в Cloud.ru"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-moscow-1"
}

variable "public_ssh_key" {
  description = "Публичный SSH-ключ"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
  default     = "cloudru-vm"
}

variable "flavor" {
  description = "Flavor виртуальной машины"
  type        = string
  default     = "lowcost10-1-1"
}

variable "image_id" {
  description = "ID образа Ubuntu 24.04"
  type        = string
  # Замените на реальный ID образа из Cloud.ru
  default     = "img-xxxxxxxx"
}
