resource "yandex_compute_instance" "kibana" {
  folder_id   = var.folder_id
  service_account_id = var.service_account_id
  name        = "yc-auto-instance-kibana"
  hostname    = "yc-auto-instance-kibana"
  description = "yc-auto-instance-kibana"
  zone        = element(var.zones, 0)
  platform_id = var.instance_platform

  resources {
    core_fraction = var.core_fraction_vm
    cores  = var.instance_cores
    memory = 3
  }

  scheduling_policy {
    preemptible = var.scheduling_policy_vm
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.base_image.id
      type     = "network-hdd"
      size     = "5"
    }
  }

  network_interface {
    subnet_id = element(local.subnet_ids, 0)
    nat       = true # true if need external IP
    security_group_ids = [yandex_vpc_security_group.vm-kibana.id]
  }

  metadata = {
    ssh-keys = "debian:${file(var.public_key_path)}"
  }
  depends_on = [ yandex_compute_instance.bastion ]
}

resource "local_file" "kibana" {
  content = templatefile("~/diploma/kibana.tpl",
    {
      elast_ip = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
    }
  )
  filename = "./dest/kibana/templates/kibana.yml.j2"
  file_permission = "0644"
  depends_on = [ yandex_compute_instance.elasticsearch ]
}

resource "null_resource" "kibana" {
  provisioner "local-exec" {
    command = <<EOT
      export ANSIBLE_HOST_KEY_CHECKING=False;
      export ANSIBLE_SSH_COMMON_ARGS='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -i ./keys/id_ed25 debian@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} -W %h:%p"';
      ansible-playbook -u debian -i '${yandex_compute_instance.kibana.network_interface.0.ip_address},' --private-key=./keys/id_ed25 ./dest/kibana.yml
    EOT
  }
  depends_on = [ local_file.kibana, null_resource.node ]
}

