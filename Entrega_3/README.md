# Despliegue de Jenkins con Docker y Terraform

Este documento describe los pasos necesarios para replicar el proceso completo de despliegue.

## Requisitos previos

1. **Docker**: Instalar Docker en el sistema operativo host.
2. **Terraform**: Asegurarse de tener instalada una versión compatible de Terraform.
3. **Acceso a internet**: Para descargar las imágenes de Docker y los plugins de Jenkins.
4. **Archivos del proyecto**: Descargar y ubicar en el mismo directorio los siguientes archivos:
   - `Dockerfile`
   - `dind.tf`
   - `jenkins.tf`
   - `main.tf`
   - `variables.tf`

## Pasos para el despliegue

### 1. Crear la imagen personalizada de Jenkins

1. Abrir una terminal y ubicarse en el directorio donde se encuentra el archivo `Dockerfile`.
2. Construir la imagen personalizada de Jenkins ejecutando el siguiente comando:

   ```bash
   docker build -t jenkins_entrega3:2.479.2-jdk17 .
   ```

   Esto crea una imagen basada en `jenkins/jenkins:2.479.2-jdk17` con soporte para Docker CLI y plugins adicionales.

### 2. Configurar y desplegar los contenedores con Terraform

1. Inicializar Terraform en el directorio del proyecto:

   ```bash
   terraform init
   ```

2. Validar la configuración de los archivos de Terraform:

   ```bash
   terraform validate
   ```

3. Aplicar la configuración para desplegar los contenedores:

   ```bash
   terraform apply
   ```

   - Confirmar escribiendo `yes` cuando se solicite.
   - Este proceso creará una red, volúmenes y los contenedores de Jenkins y `dind` (Docker-in-Docker).

### 3. Acceder a Jenkins

1. Abrir un navegador web y acceder a Jenkins utilizando la dirección `http://localhost:8080`.
2. Durante el primer acceso, Jenkins solicitará una contraseña inicial que se encuentra en el contenedor. Para obtenerla, ejecutar:

   ```bash
   docker exec jenkins_container cat /var/jenkins_home/secrets/initialAdminPassword
   ```

3. Copiar y pegar la contraseña en el navegador y seguir el asistente para completar la configuración inicial.

### 4. Configurar Jenkins para usar Docker

1. Instalar el plugin **Docker Pipeline** si no está ya instalado.
2. Configurar un nuevo nodo:
   - Ir a `Administrar Jenkins > Configuración del sistema > Nodos y entornos de nube`.
   - Crear un nuevo nodo con la configuración necesaria para ejecutar tareas de Docker.
3. Establecer los siguientes parámetros en Jenkins:
   - `DOCKER_HOST`: `tcp://docker:2376`
   - `DOCKER_CERT_PATH`: `/certs/client`
   - `DOCKER_TLS_VERIFY`: `1`

### 5. Verificar el despliegue

1. Crear un pipeline simple en Jenkins para ejecutar comandos Docker.
2. Asegurarse de que el contenedor Jenkins pueda interactuar con el servicio Docker-in-Docker correctamente.

## Archivos importantes

- **Dockerfile**: Define la imagen personalizada de Jenkins.
- **dind.tf**: Configura el contenedor Docker-in-Docker.
- **jenkins.tf**: Configura el contenedor de Jenkins y lo conecta con `dind`.
- **main.tf**: Define los recursos de red y volúmenes necesarios.
- **variables.tf**: Contiene las variables configurables para el despliegue.

## Limpieza de recursos

Para eliminar todos los recursos creados por Terraform, ejecutar:

```bash
terraform destroy
```

Confirma escribiendo `yes` para proceder con la eliminación.

***

