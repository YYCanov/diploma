resource "yandex_vpc_network" "network" {
  name = "yc-auto-subnet"
}

resource "yandex_vpc_subnet" "subnet" {
  count          = var.cluster_size > length(var.zones) ? length(var.zones) : var.cluster_size
  name           = "yc-auto-subnet-${count.index}"
  zone           = element(var.zones, count.index)
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.110.${count.index}.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

locals {
  subnet_ids = yandex_vpc_subnet.subnet.*.id
  internal_ips = yandex_compute_instance.node.*.network_interface.0.ip_address
  inst_list = toset(range(var.cluster_size))
  zones_list = yandex_vpc_subnet.subnet.*.zone
}

resource "yandex_alb_target_group" "my-target-group" {
  name      = "my-target-group"

  dynamic "target" {
    for_each = "${toset(local.inst_list)}"
    content {  
      subnet_id = element(local.subnet_ids, target.value)
      ip_address = element(local.internal_ips, target.value)
    }
  }
}

resource "yandex_alb_backend_group" "my-backend-group" {
  name                     = "my-backend-group"
  # session_affinity {
  #   connection {
  #     source_ip = false # true for requests from one user session to be processed by the same application endpoint
  #   }
  # }

  http_backend {
    name                   = "my-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.my-target-group.id]
    load_balancing_config {
      panic_threshold      = 50
    }    
    healthcheck {
      timeout              = "3s"
      interval             = "1s"
      healthy_threshold    = 1
      unhealthy_threshold  = 2
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
  # depends_on = [ yandex_alb_target_group.my-target-group ]
}

resource "yandex_alb_http_router" "my-router" {
  name   = "my-router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "my-virtual-host"
  http_router_id = yandex_alb_http_router.my-router.id
  route {
    name = "my-http-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.my-backend-group.id
        timeout          = "3s"
      }
    }
  }
}    

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "my-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "my-route-table"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}