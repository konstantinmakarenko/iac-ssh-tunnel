# ===== ДАННЫЕ ОБ ОБРАЗЕ =====
data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 24.04 LTS 64-bit"
  most_recent = true
}

# ===== КЛЮЧ =====
resource "openstack_compute_keypair_v2" "admin_key" {
  name       = "sel-key-2026"
  public_key = var.public_ssh_key
}

# ===== СЕТЬ =====
resource "openstack_networking_network_v2" "network" {
  name = "sel-network"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "sel-subnet"
  network_id = openstack_networking_network_v2.network.id
  cidr       = "192.168.1.0/24"
  ip_version = 4
}

# ===== РОУТЕР ДЛЯ ДОСТУПА В ИНТЕРНЕТ =====
resource "openstack_networking_router_v2" "router" {
  name           = "sel-router"
  admin_state_up = true
}

resource "openstack_networking_router_interface_v2" "router_iface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

# ===== ВИРТУАЛЬНАЯ МАШИНА =====
resource "openstack_compute_instance_v2" "vm" {
  name        = "sel-vm"
  flavor_name = "SL1.1-1024"
  key_pair    = openstack_compute_keypair_v2.admin_key.name

  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu.id
    source_type           = "image"
    volume_size           = 15
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network.name
  }
}

# ===== ПУБЛИЧНЫЙ IP =====
resource "selectel_vpc_floatingip_v2" "vm_floatingip" {
  project_id = var.project_id
  region     = var.region
}

resource "openstack_networking_floatingip_associate_v2" "vm_fip_assoc" {
  floating_ip = selectel_vpc_floatingip_v2.vm_floatingip.floating_ip_address
  port_id     = openstack_compute_instance_v2.vm.network[0].port
}