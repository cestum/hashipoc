job "trains-server" {
  datacenters = ["dc1"]

  update {
    stagger = "10s"
    max_parallel = 1
  }
  
  meta {
    ES_CLUSTER_NAME = "${NOMAD_REGION}-${NOMAD_JOB_NAME}"
  }

  #API server
  group "apiserver" {

    affinity {
      attribute = "${attr.unique.hostname}"
      value ="node2"
      weight = 80
    }
    update {
        max_parallel     = 1
        min_healthy_time = "30s"
        healthy_deadline = "5m"
        auto_revert      = true
        auto_promote     = false
    }
    
    network {
      mode = "bridge"
      port "http" {
	     static = 8008
	     to     = 8008
	   }      
    }

    service {
      name = "trains-apiserver"
      port = "8008"

      connect {
        sidecar_service {
	        proxy {
	            upstreams {
	              destination_name = "trains-elastic"
	              local_bind_port  = 19200
	            }
	            upstreams {
	              destination_name = "trains-redis"
	              local_bind_port  = 16379
	            }
	            upstreams {
	              destination_name = "trains-mongo"
	              local_bind_port  = 27018
	            }	            
	        }	        
        }
      }
    }


    task "apiserver" {

      meta {
        tag = "v1"
      }

      driver = "docker"

      config {
        image = "allegroai/trains:latest"
        command = "apiserver"
        volumes = [
              "/opt/trains/logs:/var/log/trains",
              "/opt/trains/config:/opt/trains/config",
              "/opt/trains/server-config:/opt/trains/server/config/default"
            ]
      }

      #template {
      #  source = "/opt/trains/config/default/hosts.conf.tpl"
      #  destination = "/opt/trains/server/config/default/hosts.conf"
      #  change_mode = "signal"
      #}

    }

  }

  #elastic search
  group "elasticsearch" {
    network {
      mode = "bridge"
      port "http" {
	     static = 9200
	     to     = 9200
	   }
    }

    service {
      name = "trains-elastic"
      port = "9200"

      connect {
        sidecar_service {}
      }
    }


    task "elasticsearch" {
      driver = "docker"

      config {
        image = "docker.elastic.co/elasticsearch/elasticsearch:5.6.16"
        command = "elasticsearch"
        args = [ 
        	"-Ebootstrap.memory_lock=true",
        	"-Ecluster.name=${NOMAD_META_ES_CLUSTER_NAME}",
        	"-Ecluster.routing.allocation.node_initial_primaries_recoveries=500",
        	"-Ediscovery.zen.minimum_master_nodes=1",
        	"-Ehttp.compression_level=7",
        	"-Enode.ingest=true",
        	"-Enode.name=${NOMAD_META_ES_CLUSTER_NAME}",
        	"-Ereindex.remote.whitelist='*.*'",
        	"-Escript.inline=true",
        	"-Escript.painless.regex.enabled=true",
          "-Escript.update=true",
          "-Ethread_pool.bulk.queue_size=2000",
          "-Ethread_pool.search.queue_size=10000",
          "-Expack.monitoring.enabled=false",
          "-Expack.security.enabled=false"
        ]
        ulimit {
          # ensure elastic search can lock all memory for the JVM on start
          memlock = "-1"

          # ensure elastic search can create enough open file handles
          nofile = "65536"
        }
        volumes = [
        	"/opt/trains/data/elastic:/usr/share/elasticsearch/data"
        ]
      }
      env {
        ES_JAVA_OPTS = "-Xmx2g -Xms2g"
      }

		resources {
			cpu = 1512
        	memory = 3096
		}  

    }
  }

  group "fileserver" {
    affinity {
      attribute = "${attr.unique.hostname}"
      value ="node2"
      weight = 50
    }    
    network {
      mode = "bridge"
      port "http" {
	     static = 8081
	     to     = 8081
	   }        
    }

    service {
      name = "trains-fileserver"
      port = "8081"

      connect {
        sidecar_service {}
      }
    }


    task "fileserver" {
      driver = "docker"
      config {
        image = "allegroai/trains:latest"
        command = "fileserver"       
        volumes = [
          "/opt/trains/logs:/var/log/trains",
          "/opt/trains/data/fileserver:/mnt/fileserver"
        ]
      }
  
    }
  }




  group "mongo" {
    network {
      mode = "bridge"
      port "http" {
	     static = 27017
	     to     = 27017
	   }       
    }

    service {
      name = "trains-mongo"
      port = "27017"

      connect {
        sidecar_service {}
      }
    }


    task "mongo" {
      driver = "docker"

      config {
        image = "mongo:3.6.5"
        volumes = [
        	"/opt/trains/data/mongo/db:/data/db",
        	"/opt/trains/data/mongo/configdb:/data/configdb"
        ]
      }   
    }
  }




  group "redis" {
    network {
      mode = "bridge"
      port "http" {
	     static = 6379
	     to     = 6379
	   }       
    }

    service {
      name = "trains-redis"
      port = "6379"

      connect {
        sidecar_service {}
      }
    }


    task "redis" {
      driver = "docker"

      config {
        image = "redis:5.0"

        volumes = [
        	"/opt/trains/data/redis:/data"
        ]
      }
    }
  }

  group "webserver" {
    affinity {
      attribute = "${attr.unique.hostname}"
      value ="node2"
      weight = 80
    }
    network {
      mode = "bridge"
      port "http" {
	     static = 8080
	     to     = 80
	   }       
    }

    service {
      name = "trains-webserver"
      port = "8080"

      connect {
        sidecar_service {}
      }
    }


    task "webserver" {
      driver = "docker"

      config {
        image = "allegroai/trains:latest"
        command = "webserver"
        volumes = [
        	"/opt/trains/logs:/var/log/trains"
        ]
      }
    }
  }
}
