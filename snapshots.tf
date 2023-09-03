# resource "yandex_compute_snapshot" "snapshot-1" {
#   name           = "disk-snapshot"
#   source_disk_id = "<идентификатор диска>"
# }

resource "yandex_compute_snapshot_schedule" "default" {
  name = "snapshot-mine"
  schedule_policy {
    expression = "0 0 ? * *"
  }
  snapshot_count = 7
#   snapshot_spec {
#     description = "retention-snapshot"
#   }
  disk_ids = concat(
    yandex_compute_instance.node[*].boot_disk.0.disk_id,
    [
        yandex_compute_instance.prometheus.boot_disk.0.disk_id, 
        yandex_compute_instance.elasticsearch.boot_disk.0.disk_id,
        yandex_compute_instance.kibana.boot_disk.0.disk_id,
        yandex_compute_instance.grafana.boot_disk.0.disk_id,
        yandex_compute_instance.bastion.boot_disk.0.disk_id
    ]
  )
}

# https://cloud.yandex.ru/docs/compute/operations/snapshot-control/create-schedule
# https://terraform-provider.yandexcloud.net/Resources/compute_snapshot_schedule

