resource "yandex_compute_instance" "prometheus" {
  folder_id   = var.folder_id
  service_account_id = var.service_account_id
  name        = "yc-auto-instance-prometheus"
  hostname    = "yc-auto-instance-prometheus"
  description = "yc-auto-instance-prometheus of my cluster"
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
    nat       = false # true if need external IP
    security_group_ids = [yandex_vpc_security_group.vm-prometheus.id]
  }

  metadata = {
    ssh-keys = "debian:${file(var.public_key_path)}"
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 50;
      export ANSIBLE_HOST_KEY_CHECKING=False;
      export ANSIBLE_SSH_COMMON_ARGS='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -i ./keys/id_ed25 debian@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} -W %h:%p"';
      ansible-playbook -u debian -i '${self.network_interface.0.ip_address},' --private-key=./keys/id_ed25 ./dest/prometheus.yml
    EOT
  }
  depends_on = [ yandex_compute_instance.bastion ]
}