resource "yandex_compute_disk" "additional_disk" {
  count = 3
  name  = "disk-${count.index + 1}"
  type  = "network-hdd"
  size  = 1
}
resource "yandex_compute_instance" "storage" {
  name = "storage"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.additional_disk
    content {
      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}
