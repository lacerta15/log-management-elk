#!/usr/bin/env bash
# Install and configure Filebeat on a remote host
HOST="${1:?Usage: $0 <host>}"
LOGSTASH_HOST="${LOGSTASH_HOST:-elk.example.com}"
LOGSTASH_PORT="${LOGSTASH_PORT:-5044}"
ELK_VERSION="${ELK_VERSION:-8.10.0}"

echo "Installing Filebeat on $HOST..."
ssh "$HOST" "
  rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch 2>/dev/null || true
  cat > /etc/yum.repos.d/elastic.repo << 'EOF'
[elastic-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
  yum install -y filebeat-${ELK_VERSION} 2>/dev/null || dnf install -y filebeat 2>/dev/null
" 2>/dev/null

# Configure
ssh "$HOST" "cat > /etc/filebeat/filebeat.yml" << FBEOF
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/messages
      - /var/log/secure
      - /var/log/audit/audit.log
    fields:
      host_env: production
    multiline.pattern: '^[[:space:]]'
    multiline.negate: false
    multiline.match: after

  - type: log
    enabled: true
    paths:
      - /var/log/cloudera-scm-server/*.log
      - /var/log/hadoop-hdfs/*.log
      - /var/log/hadoop-yarn/*.log
    fields:
      service_type: cloudera

output.logstash:
  hosts: ["${LOGSTASH_HOST}:${LOGSTASH_PORT}"]

logging.level: warning
FBEOF

ssh "$HOST" "systemctl enable --now filebeat"
echo "✅ Filebeat installed on $HOST"
