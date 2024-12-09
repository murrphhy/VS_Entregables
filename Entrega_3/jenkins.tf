resource "null_resource" "build_jenkins_image" {
  provisioner "local-exec" {
    command = "docker build -t jenkins_entrega3:2.479.2-jdk17 ."
  }
}

resource "docker_container" "jenkins_container" {
  depends_on = [null_resource.build_jenkins_image]
  image      = "jenkins_entrega3:2.479.2-jdk17"
  name       = var.jenkins_container_name

  user = "root"

  ports {
    internal = 8080
    external = 8080
  }
  ports {
    internal = 50000
    external = 50000
  }
  volumes {
    volume_name    = docker_volume.jenkins_data.name
    container_path = "/var/jenkins_home"
  }
  volumes {
    volume_name    = docker_volume.jenkins_certs.name
    container_path = "/certs/client"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.red_ejercicio.name
  }

  env = [
    "JAVA_OPTS=-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true",
    "DOCKER_HOST=tcp://docker:2376",
    "DOCKER_CERT_PATH=/certs/client",
    "DOCKER_TLS_VERIFY=1"
  ]
}
