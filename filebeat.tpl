#jinja2: lstrip_blocks: "True"
{{ filebeat_var_config | to_nice_yaml(indent=2) }}

output.elasticsearch:
  hosts: ["${elast_ip}:9200"]
  protocol: "http"

setup.kibana:
  host: "${kibana_ip}:5601"