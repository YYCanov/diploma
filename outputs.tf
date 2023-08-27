output "Load_Balancer_IP" {
  value = yandex_alb_load_balancer.my-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

output "Grafana_IP" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "Kibana_IP" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}