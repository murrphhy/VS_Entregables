resource "docker_image" "dind_image" {
  name         = "docker:latest"
  keep_locally = false
}

resource "docker_container" "dind_container" {
  name  = var.dind_container_name
  image = docker_image.dind_image.image_id

  privileged = true

  ports {
    internal = 2376
    external = 2376
  }
  volumes {
    volume_name    = docker_volume.jenkins_certs.name
    container_path = "/certs/client"
  }
  volumes {
    volume_name    = docker_volume.jenkins_data.name
    container_path = "/var/jenkins_home"
  }

  networks_advanced {
    name = docker_network.red_ejercicio.name
    aliases = [ "docker" ]
  }

  env = [
    "DOCKER_TLS_CERTDIR=/certs"
  ]
}
