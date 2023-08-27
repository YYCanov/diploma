terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

locals {
  instance_internal_ips = yandex_compute_instance.node.*.network_interface.0.ip_address
  # hostnames_ips = [yandex_compute_instance.node.*.hostname, yandex_compute_instance.node.*.network_interface.0.nat_ip_address]
}

data "yandex_compute_image" "base_image" {
  # source_family = var.yc_image_family
  family = var.yc_image_family
}

resource "yandex_compute_instance" "node" {
  folder_id   = var.folder_id
  service_account_id = var.service_account_id
  count       = var.cluster_size
  name        = "yc-auto-instance-${count.index}"
  hostname    = "yc-auto-instance-${count.index}"
  description = "yc-auto-instance-${count.index} of my cluster"
  zone        = element(var.zones, count.index)
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
    subnet_id = element(local.subnet_ids, count.index)
    nat       = false # true if need external IP
    security_group_ids = [yandex_vpc_security_group.alb-vm-sg.id]
  }

  metadata = {
    ssh-keys = "debian:${file(var.public_key_path)}"
    user-data = file("metadata.yaml")
  }

  labels = {
    node_id = count.index
  }
}

resource "null_resource" "node" {
  count = var.cluster_size
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      export ANSIBLE_HOST_KEY_CHECKING=False;
      export ANSIBLE_SSH_COMMON_ARGS='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -i ./keys/id_ed25 debian@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} -W %h:%p"';
      ansible-playbook -u debian -i '${element(local.internal_ips, count.index)},' --private-key=./keys/id_ed25 ./dest/ans.yml
    EOT
  }
  depends_on = [ yandex_compute_instance.bastion, yandex_vpc_gateway.nat_gateway, yandex_compute_instance.elasticsearch ]
}

resource "local_file" "nodes" {
  content = templatefile("~/diploma/nodes.tpl",
    {
      node_exp = yandex_compute_instance.node.*.network_interface.0.ip_address
    }
  )
  filename = "./dest/prometheus/templates/prometheus.yml.j2"
  file_permission = "0644"
  depends_on = [ yandex_compute_instance.node ]
}

resource "local_file" "filebeat_node" {
  content = templatefile("~/diploma/filebeat.tpl",
    {
      elast_ip = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
      kibana_ip = yandex_compute_instance.kibana.network_interface.0.ip_address
    }
  )
  filename = "./dest/ans/templates/filebeat.yml.j2"
  file_permission = "0644"
  depends_on = [ yandex_compute_instance.elasticsearch, yandex_compute_instance.kibana ]
}