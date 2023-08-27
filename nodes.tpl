#jinja2: lstrip_blocks: "True"
{{ prometheus_var_config | to_nice_yaml(indent=2) }}

- job_name: nodes_metrics
  scrape_interval: 15s
  metrics_path: /metrics
  static_configs:
  - targets:
%{ for ip in node_exp ~}
    - ${ip}:9100
%{ endfor ~}

- job_name: nginx_metrics
  scrape_interval: 15s
  metrics_path: /metrics
  static_configs:
  - targets:
%{ for ip in node_exp ~}
    - ${ip}:4040
%{ endfor ~}