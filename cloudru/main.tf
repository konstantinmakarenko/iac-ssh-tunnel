# ===== ДАННЫЕ ОБ ОБРАЗЕ =====
data "cloudru_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
  latest = true
}

# ===== SSH-КЛЮЧ =====
# В Cloud.ru Evolution ключ передаётся напрямую в ресурс ВМ
# Отдельный ресурс для ключа не требуется

# ===== СЕТЬ =====
resource "cloudru_vpc_vpc" "main" {
  name = "cloudru-network"
}

resource "cloudru_compute_subnet" "subnet" {
  name   = "cloudru-subnet"
  cidr   = "192.168.1.0/24"
  zone   = var.zone
  vpc_id = cloudru_vpc_vpc.main.id
}

# ===== ВИРТУАЛЬНАЯ МАШИНА =====
resource "cloudru_compute_vm" "vm" {
  name        = "cloudru-vm"
  zone        = var.zone
  image_id    = data.cloudru_compute_image.ubuntu.id
  flavor_name = "s7n.medium-2"  # 2 vCPU, 4 GB RAM (минимальный доступный)
  ssh_keys    = [var.public_ssh_key]

  # User-data для настройки ВМ
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    echo "=== Starting user_data script ===" >> /var/log/user-data.log

    # Создаём папку для SSH-ключей (на всякий случай)
    mkdir -p /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh

    # Добавляем публичный ключ
    echo "${var.public_ssh_key}" > /home/ubuntu/.ssh/authorized_keys

    # Устанавливаем правильные права
    chmod 600 /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh

    # Включаем IP forwarding
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    echo "=== user_data script finished successfully ===" >> /var/log/user-data.log
  EOF
  )

  network_interface {
    subnet_id = cloudru_compute_subnet.subnet.id
  }

  boot_disk {
    size = 15
    type = "ssd"
  }
}

# ===== ПУБЛИЧНЫЙ IP =====
# Создаём Floating IP
resource "cloudru_compute_floating_ip" "vm_floating_ip" {}

# Привязываем Floating IP к ВМ
resource "cloudru_compute_floating_ip_associate" "vm_floating_ip_assoc" {
  floating_ip_id = cloudru_compute_floating_ip.vm_floating_ip.id
  instance_id    = cloudru_compute_vm.vm.id
}