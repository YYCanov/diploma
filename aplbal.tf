resource "yandex_alb_load_balancer" "my-balancer" {
  name        = "alb-my"
  network_id  = yandex_vpc_network.network.id
  security_group_ids = [yandex_vpc_security_group.alb-sg.id]

  allocation_policy {
    dynamic "location" {
        for_each = "${toset(range(length(local.subnet_ids)))}"
          content {  
            subnet_id = element(local.subnet_ids, location.value)
            zone_id   = element(local.zones_list, location.value)
          }
      }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.my-router.id
      }
    }
  }
}