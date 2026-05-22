# log-management-elk
Centralized log management with ELK (Elasticsearch, Logstash, Kibana) + Filebeat.

## Architecture
```
Servers → Filebeat → Logstash → Elasticsearch → Kibana
```

## Quick Start
```bash
cd docker/ && docker-compose up -d
./scripts/install_filebeat.sh server1.example.com
./scripts/create_index_template.sh
```
