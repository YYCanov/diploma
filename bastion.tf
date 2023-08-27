resource "yandex_compute_instance" "bastion" {
  folder_id   = var.folder_id
  service_account_id = var.service_account_id
  name        = "yc-auto-instance-bastion"
  hostname    = "yc-auto-instance-bastion"
  description = "yc-auto-instance-bastion of my cluster"
  zone        = element(var.zones, 0)
  platform_id = var.instance_platform

  resources {
    core_fraction = 20 # No need 100% for test
    cores  = var.instance_cores
    memory = var.instance_memory
  }

  scheduling_policy {
    preemptible = true # No need fulltime for test
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.base_image.id
      type     = "network-hdd"
      size     = "3"
    }
  }

  network_interface {
    subnet_id = element(local.subnet_ids, 0)
    nat       = true # true if need external IP
    security_group_ids = [yandex_vpc_security_group.vm-bastion.id]
  }

  metadata = {
    ssh-keys = "debian:${file(var.public_key_path)}"
    user-data = file("metadata.yaml")
  }
}