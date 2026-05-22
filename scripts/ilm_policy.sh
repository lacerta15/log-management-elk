#!/usr/bin/env bash
# Create ILM policy for log retention
ES_HOST="${ES_HOST:-localhost:9200}"
curl -s -X PUT "http://${ES_HOST}/_ilm/policy/syslog-policy"     -H "Content-Type: application/json"     -d '{
  "policy": {
    "phases": {
      "hot":    {"actions": {"rollover": {"max_age": "1d", "max_size": "5gb"}}},
      "warm":   {"min_age": "7d",  "actions": {"forcemerge": {"max_num_segments": 1}}},
      "cold":   {"min_age": "30d", "actions": {"freeze": {}}},
      "delete": {"min_age": "90d", "actions": {"delete": {}}}
    }
  }
}' | python3 -m json.tool
echo "ILM policy created: syslog-policy"
