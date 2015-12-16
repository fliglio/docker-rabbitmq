#!/bin/bash


read -r -d '' CONN_CFG << EOF
user: guest
password: guest
vhost: /
servicename: rabbitmq
EOF

read -r -d '' RABBIT_SVC << EOF
{
  "ID": "rabbitmq1",
  "Name": "rabbitmq",
  "Address": "127.0.0.1",
  "Port": 5672
}
EOF

#consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul &

#PID=$!

sleep 3

curl -X PUT http://127.0.0.1:8500/v1/agent/service/register -d "$RABBIT_SVC"
curl -s -X PUT http://127.0.0.1:8500/v1/kv/chinchilla/connection.yaml -d "$CONN_CFG"


#kill $PID
