# Terraform-конфигурация этого файла описывает часть облачной инфраструктуры.


# Создаём облачную сеть.
resource "cloudru_evolution_vpc_vpc" "main" {
  project_id  = var.project_id
  name        = "tf-evo-vpc"
  description = "VPC для Terraform"
}

# Описываем подсеть и её адресный диапазон.
resource "cloudru_evolution_compute_subnet" "subnet" {
  project_id = var.project_id
  name       = "tf-evo-subnet"
  zone_identifier = {
    name = var.zone
  }
  description    = "Подсеть для ВМ"
  subnet_address = "192.168.1.0/24"
  routed_network = true
  default        = false
  vpc_id         = cloudru_evolution_vpc_vpc.main.id
  dns_servers = {
    value = ["8.8.4.4", "8.8.8.8"]
  }
}

# Группа безопасности ограничивает сетевой доступ к ВМ.
resource "cloudru_evolution_compute_security_group" "allow_ssh" {
  project_id = var.project_id
  name       = "tf-evo-sg"
  zone_identifier = {
    name = var.zone
  }
  description = "Группа безопасности для ВМ"
}

# Правило открывает только нужный тип трафика.
resource "cloudru_evolution_compute_security_group_rule" "ingress_ssh" {
  security_group_id = cloudru_evolution_compute_security_group.allow_ssh.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "22:22"
  description       = "SSH доступ"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Правило открывает только нужный тип трафика.
resource "cloudru_evolution_compute_security_group_rule" "egress_all" {
  security_group_id = cloudru_evolution_compute_security_group.allow_ssh.id
  direction         = "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "1:65535"
  description       = "Разрешить весь исходящий TCP"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Создаём сетевой интерфейс для подключения ВМ к подсети.
resource "cloudru_evolution_compute_interface" "vm_interface" {
  project_id = var.project_id
  name       = "tf-evo-interface"
  zone_identifier = {
    name = var.zone
  }
  description                = "Сетевой интерфейс для ВМ"
  subnet_id                  = cloudru_evolution_compute_subnet.subnet.id
  interface_security_enabled = true
  security_groups_identifiers = {
    value = [{
      id = cloudru_evolution_compute_security_group.allow_ssh.id
    }]
  }
  type = "INTERFACE_TYPE_REGULAR"

  external_ip_specs = {
    new_external_ip = true
  }
}

# Создаём загрузочный диск виртуальной машины.
resource "cloudru_evolution_compute_disk" "vm_disk" {
  project_id = var.project_id
  name       = "tf-evo-disk"
  size       = 15
  zone_identifier = {
    name = var.zone
  }
  disk_type_identifier = {
    name = "SSD"
  }
  description = "Загрузочный диск для ВМ"
  bootable    = true
  image_id    = var.image_id
  encrypted   = false
  readonly    = false
  shared      = false
}

# Создаём виртуальную машину с SSH-доступом.
resource "cloudru_evolution_compute_vm" "vm" {
  project_id = var.project_id
  name       = var.vm_name
  zone_identifier = {
    name = var.zone
  }
  flavor_identifier = {
    name = var.flavor
  }
  description = "ВМ, созданная через Terraform"
  disk_identifiers = [{
    disk_id = cloudru_evolution_compute_disk.vm_disk.id
  }]
  network_interfaces = [{
    interface_id = cloudru_evolution_compute_interface.vm_interface.id
  }]
  # Cloud-init настраивает SSH и сетевые параметры внутри ВМ.
  cloud_init_userdata = base64encode(<<-EOF
    #!/bin/bash
    mkdir -p /home/ubuntu/.ssh
    echo "${var.public_ssh_key}" > /home/ubuntu/.ssh/authorized_keys
    chmod 700 /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
  EOF
  )
}
