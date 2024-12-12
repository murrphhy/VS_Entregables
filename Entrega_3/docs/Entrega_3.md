# Entrega 3

- [Entrega 3](#entrega-3)
- [Explicación Entrega 3](#explicación-entrega-3)
      - [Enunciado](#enunciado)
    - [Introducción entregable 3](#introducción-entregable-3)
      - [Explicación archivos](#explicación-archivos)
    - [Explicación Dockerfile](#explicación-dockerfile)
      - [Explicación archivos de configuración de Terraform](#explicación-archivos-de-configuración-de-terraform)
    - [Explicación main.tf](#explicación-maintf)
    - [Explicación variables.tf](#explicación-variablestf)
    - [Explicación dind.tf](#explicación-dindtf)
    - [Explicación jenkins.tf](#explicación-jenkinstf)
    - [Archivo jenkinsfile](#archivo-jenkinsfile)
        - [Bibliografía](#bibliografía)


Relizado por:

- David Massa Gallego
- Julio Martín García



# Explicación Entrega 3

#### Enunciado
Debéis realizar un despliegue de una aplicación Python mediante un pipeline de Jenkins de manera similar al ejemplo visto en clase para desplegar una aplicación React. Podéis consultar todos los detalles en el PDF de la sesión de Jenkins.
Para este ejercicio, el repositorio de la aplicación Python a "forkear" es el siguiente: https://github.com/jenkins-docs/simple-python-pyinstaller-app
El siguiente tutorial contiene un despliegue de dicha aplicación, pero tened en cuenta que no usa DinD como agente, por lo que usa otros agentes a los vistos en clase: https://www.jenkins.io/doc/tutorials/build-a-python-app-with-pyinstaller/
La base del ejercicio es la misma que la vista en clase para la aplicación de React. La diferencia es que en este caso se trata de una aplicación Python
Por tanto, usaremos Jenkins desplegado en un contenedor Docker y un agente Docker in Docker para ejecutar el pipeline

Debéis crear un pipeline en Jenkins que realice el despliegue de la aplicación
en un contenedor Docker
El despliegue de los dos contenedores Docker necesarios (Docker in Docker y
Jenkins) debe realizarse mediante Terraform. Para crear la imagen
personalizada de Jenkins debéis usar un Dockerfile tal como hemos visto en
clase, esto no tiene que realizarse mediante Terraform
El despliegue desde el pipeline debe hacerse usando una rama llamada main

- En la rama main , debéis crear una carpeta docs en la raíz del repositorio donde debéis incluir:
  - El Dockerfile para crear la imagen personalizada de Jenkins
  - Los archivos de configuración de Terraform
  - Un archivo llamado README.md con las instrucciones para replicar el proceso completo de despliegue: cómo crear la imagen de Jenkins, cómo desplegar los contenedores Docker con Terraform, cómo configurar Jenkins, etc.
  - El archivo Jenkinsfile con el contenido mostrado en la diapositiva
anterior

***
### Introducción entregable 3

Este proyecto tiene como objetivo crear un pipeline de CI/CD utilizando Jenkins para el despliegue de una aplicación Python basada en PyInstaller. Para ello, se implementará un entorno de despliegue compuesto por Jenkins y un agente Docker in Docker (DinD), ambos desplegados en contenedores Docker. La infraestructura necesaria será provisionada mediante Terraform, mientras que la imagen personalizada de Jenkins se generará a partir de un Dockerfile.

***
#### Explicación archivos

### Explicación Dockerfile

~~~
FROM jenkins/jenkins:2.479.2-jdk17

USER root

RUN apt-get update && apt-get install -y lsb-release

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg

RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y docker-ce-cli

USER jenkins

RUN jenkins-plugin-cli --plugins "blueocean docker-workflow token-macro json-path-api"
~~~

- Vamos a desglosarlo por parte para ver lo que hacemos exactamente con este **Dockerfile**.

1. `FROM jenkins/jenkins:2.479.2-jdk17`

Con esta línea lo que hacemos es coger una imagen con una instalación preconfigurada del servidor Jenkins. Indicamos que queremos la última versión y que venga con el entorno de ejecución de JDK 17.

1. `USER root`
   
Cambiamos a usuario root para realizar instalaciones.

1. `RUN apt-get update && apt-get install -y lsb-release`

Actualizar e instalar lsb-release.

4. 
~~~
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg
~~~

Añadir clave GPG del repositorio de Docker

5. 
~~~
RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
~~~
Este comando configura el repositorio oficial de Docker en el sistema operativo base, permitiendo instalar versiones actualizadas de Docker utilizando APT más adelante.

6. `RUN apt-get update && apt-get install -y docker-ce-cli`

Instalamos docker-ce-cli, lo que nos proporciona las herramientas necesarias para interactuar con el motor de Docker desde la línea de comandos.

7. `USER jenkins`

Volvemos al usuario Jenkins.

8. `RUN jenkins-plugin-cli --plugins "blueocean docker-workflow token-macro json-path-api"`

Instalamos plugins de Jenkins. En este caso, estamos instalando el plugin de **blueocean**, lo que nos proporciona una interfaz de usuario bastante óptima y moderna y diversas funcionalidades como la visualización de pipelines.

***
#### Explicación archivos de configuración de Terraform

### Explicación main.tf

~~~
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

~~~

Este archivo define la configuración general y los recursos compartidos (red, volúmenes) que otros recursos necesitan. Es el punto de partida porque establece la base sobre la que se construyen los contenedores.

- **terraform y provider**
  - Configura el proveedor Docker para que Terraform interactúe con él.
  - Se usa la versión ~> 3.0.1 del proveedor oficial kreuzwerker/docker.

- **docker_network**
  - Crea una red llamada red_entrega que permite que los contenedores (como Jenkins y DinD) se comuniquen entre sí.
- **docker_volume**
Crea dos volúmenes:
  -   jenkins_data: Almacena los datos persistentes de Jenkins.
  -   jenkins_certs: Guarda los certificados necesarios para la conexión segura con DinD.

### Explicación variables.tf

~~~
variable "jenkins_container_name" {
  description = "Jenkins container's name"
  type        = string
  default     = "jenkins_container"
}

variable "dind_container_name" {
  description = "dind container's name"
  type        = string
  default     = "dind_container"
}
~~~
Este archivo define las variables que otros archivos utilizan, permitiendo que los valores sean dinámicos y configurables.

- Variables:
  - jenkins_container_name: Nombre del contenedor Jenkins.
  - dind_container_name: Nombre del contenedor Docker-in-Docker.

Gracias a este archivo, puedes cambiar los nombres de los contenedores sin modificar el código directamente en los otros archivos.

### Explicación dind.tf

~~~
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
~~~

Aquí se crea un contenedor Docker-in-Docker (DinD), que Jenkins utilizará para ejecutar contenedores de forma aislada. Es necesario configurarlo antes de iniciar Jenkins.

- `docker_image`
  - Descarga la imagen oficial de Docker (docker:latest).
- `docker_container`
  - Crea un contenedor llamado dind_container (nombre definido por la variable).
  - Usa la imagen descargada previamente
  - Habilita el modo privilegiado (privileged = true) para que el contenedor pueda ejecutar Docker.

**Puertos**

- Mapea el puerto interno 2376 del contenedor al puerto externo 2376, permitiendo comunicación TLS segura.

**Volúmenes**

- Usa los volúmenes creados en main.tf para almacenar certificados (/certs/client) y datos de Jenkins (/var/jenkins_home).

**Red**

- Conecta este contenedor a la red red_entrega con el alias docker.

**Variables del entorno**

- Configura `DOCKER_TLS_CERTDIR` para indicar que se usarán certificados TLS.

### Explicación jenkins.tf

~~~
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
~~~

Finalmente, se construye la imagen de Jenkins, se lanza el contenedor y se conecta al resto de los recursos configurados anteriormente (red, volúmenes, DinD).

- `null_resource`
  - Ejecuta un comando local para construir una imagen personalizada de Jenkins llamada **jenkins_entrega3:2.479.2-jdk17** con un Dockerfile.

- `docker_container`
  - Crea un contenedor Jenkins utilizando la imagen personalizada.
  - Depende del **null_resource** para asegurarse de que la imagen se construya antes de iniciar el contenedor.

**Puertos**

- Expone los puertos 8080 (interfaz web de Jenkins) y 50000 (conexión con agentes).

**Volúmenes**

- Monta los volúmenes creados en `main.tf` para persistir datos **/var/jenkins_home** y certificados **/certs/client**.

**Red**

- Conecta este contenedor a la red **red_entrega**.

**Variables del entorno**

- Configura variables relacionadas con Docker (DOCKER_HOST, DOCKER_CERT_PATH, etc.) para que Jenkins pueda usar DinD.
***

### Archivo jenkinsfile

~~~
pipeline {
    agent none
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'python:3.12.0-alpine3.18'
                }
            }
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
                stash(name: 'compiled-results', includes: 'sources/*.py*')
            }
        }
        stage('Test') {
            agent {
                docker {
                    image 'qnib/pytest'
                }
            }
            steps {
                sh 'py.test --junit-xml test-reports/results.xml sources/test_calc.py'
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
        stage('Deliver') {
            agent any
            environment {
                VOLUME = '$(pwd)/sources:/src'
                IMAGE = 'cdrx/pyinstaller-linux:python2'
            }
            steps {
                dir(path: env.BUILD_ID) {
                    unstash(name: 'compiled-results')
                    sh "docker run --rm -v ${VOLUME} ${IMAGE} 'pyinstaller -F add2vals.py'"
                }
            }
            post {
                success {
                    archiveArtifacts "${env.BUILD_ID}/sources/dist/add2vals"
                    sh "docker run --rm -v ${VOLUME} ${IMAGE} 'rm -rf build dist'"
                }
            }
        }
    }
}
~~~

Este pipeline de Jenkins define un proceso CI/CD en tres etapas principales: Build, Test, y Deliver, utilizando diferentes agentes y herramientas para construir, probar, y empacar un programa Python.

Es el que nos viene definido en el pdf de la entrega, así que no nos vamos a parar mucho a realizar su explicación.


##### Bibliografía