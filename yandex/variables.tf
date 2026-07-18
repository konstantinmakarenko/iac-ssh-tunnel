# Terraform-конфигурация этого файла описывает часть облачной инфраструктуры.


variable "cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "folder_id" {
  description = "ID каталога Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "token" {
  description = "OAuth-токен или IAM-токен"
  type        = string
  sensitive   = true
}

variable "default_zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "public_ssh_key" {
  description = "Публичный SSH-ключ"
  type        = string
  sensitive   = true
}
