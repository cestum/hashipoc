job "jupyter" {
  datacenters = ["dc1"]
    group "jupyter" {
    network {
      mode = "bridge"
       port "http" {
	     static = 8888
	     to     = 8888
	   }     
    }

    service {
      name = "jupyter-service"
      port = "8888"

      connect {
        sidecar_service {}
      }
    }

    task "jupyter" {
      driver = "docker"

      config {
        image = "clearlinux/machine-learning-ui"
      }
    }
  }
}