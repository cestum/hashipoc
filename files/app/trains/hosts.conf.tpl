 elastic {
  events {
    hosts: [{host: "{{ env "NOMAD_UPSTREAM_IP_trains_elastic" }}", port: 19200}]
    args {
      timeout: 60
      dead_timeout: 10
      max_retries: 5
      retry_on_timeout: true
    }
    index_version: "1"
  }

  workers {
    hosts: [{host:"{{ env "NOMAD_UPSTREAM_IP_trains_elastic" }}", port:19200}]
    args {
      timeout: 60
      dead_timeout: 10
      max_retries: 5
      retry_on_timeout: true
    }
    index_version: "1"
  }
}

mongo {
  backend {
    host: "mongodb://{{ env "NOMAD_UPSTREAM_IP_trains_mongo" }}:27018/backend"
  }
  auth {
    host: "mongodb://{{ env "NOMAD_UPSTREAM_IP_trains_mongo" }}:27018/auth"
  }
}

redis {
  workers {
    host: "{{ env "NOMAD_UPSTREAM_IP_trains_redis" }}"
    port: 16379
    db: 4
  }
}