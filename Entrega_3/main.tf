terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_network" "red_ejercicio" {
  name = "red_entrega"
}

resource "docker_volume" "jenkins_data" {
  name = "jenkins_data"
}

resource "docker_volume" "jenkins_certs" {
  name = "jenkins_certs"
}

