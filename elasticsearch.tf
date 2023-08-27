resource "yandex_compute_instance" "elasticsearch" {
  folder_id   = var.folder_id
  service_account_id = var.service_account_id
  name        = "yc-auto-instance-elasticsearch"
  hostname    = "yc-auto-instance-elasticsearch"
  description = "yc-auto-instance-elasticsearch"
  zone        = element(var.zones, 0)
  platform_id = var.instance_platform

  resources {
    core_fraction = 20 # No need 100% for test
    cores  = var.instance_cores
    memory = 2
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
    security_group_ids = [yandex_vpc_security_group.vm-elasticsearch.id]
  }

  metadata = {
    ssh-keys = "debian:${file(var.public_key_path)}"
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      export ANSIBLE_HOST_KEY_CHECKING=False;
      export ANSIBLE_SSH_COMMON_ARGS='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -i ./keys/id_ed25 debian@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} -W %h:%p"';
      ansible-playbook -u debian -i '${self.network_interface.0.ip_address},' --private-key=./keys/id_ed25 ./dest/elasticsearch.yml
    EOT
  }
  depends_on = [ yandex_compute_instance.bastion ]
}
