# Entrega Docker

[TOC]

Relizado por:

- David Massa Gallego
- Julio Martín García



## Explicación Entrega 2

#### Enunciado
1. Utiliza un Vagrantfile para crear una máquina virtual donde puedas crear un cluster de kind:
El Vagrantfile debe aprovisionar la instalación de docker las de kind y kubectl pueden realizarse manualmente
2. Dentro de la máquina Vagrant, crea un cluster de kind. Debe ser accesible desde el puerto 8085 de tu máquina local
3. Usando archivos de configuración, despliega una aplicación de Drupal dentro del cluster:
- Usa la imagen oficial más reciente
- Usa una base de datos MySQL desplegada en el cluster (usa la imagen oficial)
- Usa volúmenes persistentes para almacenar los datos de MySQL y Drupal
- En la documentación de la imagen de Drupal se indica los directorios donde se almacenan los datos
- Para el directorio /var/www/html/sites de Drupal, necesitarás usar initContainers para copiar los archivos de configuración
4. Elimina todos los pods y demuestra que los datos persisten

### Introducción Entregable 2

En este entregable vamos a proceder a crear una máquina virtual con vagrant utilizando un Vagrantfile para ello. Posteriormente a esto crearemos un clúster donde implementaremos un par de pods:
1. Para el servicio de Drupal
2. Para la base de datos con MySQL

Una vez creado, podremos acceder a nuestro http://localhost:8085 como se nos exige en el enunciado y podremos disfrutar de los servicios que nos ofrece Drupal. Cuando lo configuremos y estemos ya dentro los eliminaremos para probar la persistencia de datos.


### Explicación Vagrantfile

Hemos diseñado un Vagrantfile el cual es el siguiente:

~~~
Vagrant.configure("2") do |config|
  config.vm.define "entrega2-vs" do |vm_config|
    # Configuración básica de la máquina virtual
    vm_config.vm.hostname = "entrega2-vs"
    vm_config.vm.box = "ubuntu/focal64"
    vm_config.vm.provision "shell", path: "provisioning/entrega2_VS.sh"

    #Abrimos el puerto que usamos en la máquina de Vagrant
    config.vm.network "forwarded_port", guest: 8085, host: 8085

    # Sincronizar carpeta con los .yaml a la máquina de vagrant
    vm_config.vm.synced_folder "./files", "/home/vagrant/files"

    # Configuración de recursos
    vm_config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096" # Incrementa la memoria a 4 GB
      vb.cpus = 2        # Incrementa el número de CPUs a 2
    end
  end
end
~~~

- Vamos a proceder a desglosarlo explicando la estructura de dicho archivo

1. 
~~~
Vagrant.configure("2") do |config|
  config.vm.define "entrega2-vs" do |vm_config|
~~~

Aqui definimos la máquina virtual que vamos a usar asignándole el nombre de **entrega2-vs**.

2. 
~~~
vm_config.vm.hostname = "entrega2-vs"
vm_config.vm.box = "ubuntu/focal64"
vm_config.vm.provision "shell", path: "provisioning/entrega2_VS.sh"
~~~

- `vm_config.vm.hostname = "entrega2-vs"`: Nombre del host de la máquina virtal **entrega2-vs**
- `vm_config.vm.box = "ubuntu/focal64"`: Imagen que usará Vagrant -> Ubuntu 20.04(focal64).
- `vm_config.vm.provision "shell", path: "provisioning/entrega2_VS.sh"`: Script de aprovisionamiento para ejecutar configuraciones adicionales al iniciar la máquina.

3. 
`config.vm.network "forwarded_port", guest: 8085, host: 8085`: Abrimos el puerto 8085 de la máquina anfritión para redirigirlo al puerto 8085 de la máquina virtual que usaremos con Vagrant para poder acceder a los servicios en la máquina virtual desde el anfitrión usando: `localhost:8085`.
4. 
`vm_config.vm.synced_folder "./files", "/home/vagrant/files"`: Sincronizamos la carpeta **files** de la máquina anfritiona con la carpeta **/home/vagrant/files** dentro de la máquina virtual. lo que nos permite compartir archivos entre ambos entornos y los cuales usaremos para toda la configuración de Kubernetes.
5. 
~~~
vm_config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096" # Incrementa la memoria a 4 GB
      vb.cpus = 2        # Incrementa el número de CPUs a 2
    end
~~~

- Configuramos los recursos que nos harán falta en la máquina virtual.
- `vb.memory = "4096"`: Asignamos 4GB de RAM.
- `vb.cpus = 2`: Asignamos 2 CPUs.

#### Explicación Script de aprovisionamiento

- Aunque en el enunciado sólo se nos exige la instalación de Docker, también hemos procedido a meter en el Script de aprovisionamiento la instalación tanto de **kind** como de **Kubectl**.
Vamos a proceder a explicar el Script que se encuentra en la carpeta ***provisioning*** con el nombre de ***entrega2_VS***:
~~~
#!/bin/bash

# Instalación de Docker
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker

# Añadir al usuario 'vagrant' al grupo de Docker para ejecutar comandos sin sudo
sudo usermod -aG docker vagrant

# Verificar la instalación de Docker
docker --version

# Actualización de los paquetes que nos vienen de inicio.
sudo apt-get update -y && sudo apt-get upgrade -y

# Instalación Kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Comprobación de la instalación de Kind
kind version

# Instalación de kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Verificar la instalación de kubectl
kubectl version --client --output=yaml
~~~






















