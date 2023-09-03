resource "yandex_vpc_security_group" "alb-sg" {
  name        = "alb-sg"
  network_id  = yandex_vpc_network.network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks = ["172.16.0.0/12", "10.0.0.0/8", "192.168.0.0/16"]
  }

  ingress {
    protocol          = "TCP"
    description       = "balancer"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }

  ingress {
    protocol       = "ANY"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "ANY"
    description       = "Правило разрешает проверки доступности с диапазона адресов TG"
    v4_cidr_blocks = yandex_vpc_subnet.subnet.*.v4_cidr_blocks.0
    from_port      = 0
    to_port        = 65535
  }

}

resource "yandex_vpc_security_group" "alb-vm-sg" {
  name        = "alb-vm-sg"
  network_id  = yandex_vpc_network.network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "healthcheck"
    security_group_id = yandex_vpc_security_group.alb-sg.id
    port              = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 443
  }

  ingress {
    protocol          = "TCP"
    description       = "log_exporter"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 4040
  }

  ingress {
    protocol          = "TCP"
    description       = "node_exporter"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 9100
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = [
      "10.110.0.0/24",
      "10.110.1.0/24",
      "10.110.2.0/24",
    ]
    port           = 22
  }
}

resource "yandex_vpc_security_group" "vm-bastion" {
  name        = "vm-bastion"
  network_id  = yandex_vpc_network.network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 22
  }
}

resource "yandex_vpc_security_group" "vm-prometheus" {
  name        = "vm-prometheus"
  network_id  = yandex_vpc_network.network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Prometheus port"
    v4_cidr_blocks = [
      "10.110.0.0/24",
      "10.110.1.0/24",
      "10.110.2.0/24",
    ]
    port      = 9090
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = [
      "10.110.0.0/24",
      "10.110.1.0/24",
      "10.110.2.0/24",
    ]
    port           = 22
  }
}

resource "yandex_vpc_security_group" "vm-grafana" {
  name        = "vm-grafana"
  network_id  = yandex_vpc_network.network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Grafana port"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 3000
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = [
      "10.110.0.0/24",
      "10.110.1.0/24",
      "10.110.2.0/24",
    ]
    port           = 22
  }  
}

resource "yandex_vpc_security_group" "vm-elasticsearch" {
  name        = "vm-elasticsearch"
  network_id  = yandex_vpc_network.network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Elastic port"
    v4_cidr_blocks = [
      "10.110.0.0/24",
      "10.110.1.0/24",
      "10.110.2.0/24",
    ]
    port      = 9200
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = [
      "10.110.0.0/24",
      "10.110.1.0/24",
      "10.110.2.0/24",
    ]
    port           = 22
  }
}

resource "yandex_vpc_security_group" "vm-kibana" {
  name        = "vm-kibana"
  network_id  = yandex_vpc_network.network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port      = 5601
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = [
      "10.110.0.0/24",
      "10.110.1.0/24",
      "10.110.2.0/24",
    ]
    port           = 22
  }
}