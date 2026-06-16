# ===== ДАННЫЕ ОБ ОБРАЗЕ =====
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

# ===== ВИРТУАЛЬНАЯ МАШИНА =====
resource "yandex_compute_instance" "vm" {
  name        = "yc-vm"
  platform_id = "standard-v2"
  zone        = var.default_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 15
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}

# ===== СЕТЬ =====
resource "yandex_vpc_network" "main" {
  name = "yc-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "yc-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}