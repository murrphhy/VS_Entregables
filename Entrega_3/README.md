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

### 1. Configurar y desplegar los contenedores con Terraform

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

### 2. Acceder a Jenkins

1. Abrir un navegador web y acceder a Jenkins utilizando la dirección `http://localhost:8080`.
2. Durante el primer acceso, Jenkins solicitará una contraseña inicial que se encuentra en el contenedor. Para obtenerla, ejecutar:

   ```bash
   docker exec jenkins_container cat /var/jenkins_home/secrets/initialAdminPassword
   ```

3. Copiar y pegar la contraseña en el navegador y seguir el asistente para completar la configuración inicial.

### 3. Verificar el despliegue

1. Crear un pipeline simple en Jenkins para ejecutar comandos Docker.
   1.1 Click en nuevo artículo (new item).
   1.2 Seleccionamos pipeline.
   1.3 Seleccioamos usar un scm.
   1.4 Cogemos Git.
   1.5 Copiamos y pegamos la url del repositorio (en nuestro caso el fork).
   1.6 Cambiamos la rama en la que se aplicará el pipeline (en nuestro caso, main).
   1.7 Guardamos y le damos a construir. 
3. Asegurarse de que el contenedor Jenkins pueda interactuar con el servicio Docker-in-Docker correctamente.

## Archivos importantes

- **Dockerfile**: Define la imagen personalizada de Jenkins.
- **dind.tf**: Configura el contenedor Docker-in-Docker.
- **jenkins.tf**: Configura el contenedor de Jenkins.
- **main.tf**: Define los recursos que van a usar ambos contenedores.
- **variables.tf**: Contiene las variables que se usarán en los .tf.

## Limpieza de recursos

Para eliminar todos los recursos creados por Terraform, ejecutar:

```bash
terraform destroy
```

Confirma escribiendo `yes` para proceder con la eliminación.

***

