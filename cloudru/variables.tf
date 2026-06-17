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