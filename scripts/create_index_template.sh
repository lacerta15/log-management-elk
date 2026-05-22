#!/usr/bin/env bash
# Create Elasticsearch index template for syslog
ES_HOST="${ES_HOST:-localhost:9200}"
echo "Creating index template on $ES_HOST..."
curl -s -X PUT "http://${ES_HOST}/_index_template/syslog"     -H "Content-Type: application/json"     -d '{
  "index_patterns": ["syslog-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "syslog-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": {"type": "date"},
        "host": {"type": "keyword"},
        "message": {"type": "text"},
        "syslog_hostname": {"type": "keyword"},
        "syslog_program": {"type": "keyword"},
        "src_ip": {"type": "ip"},
        "ssh_user": {"type": "keyword"},
        "tags": {"type": "keyword"}
      }
    }
  }
}' | python3 -m json.tool
