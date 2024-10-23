# Práctica 3 VS

## Explicación

En la primera parte de la práctica estamos creando un entorno donde se puede gestionar un sitio web basado en el servicio que nos proporciona Drupal, a raíz de una base de datos MySQL que es donde se guardará toda la información que la web necesite.

Para ello lo hacemos mediante un archivo llamado `docker-compose.yml`, el cual nos ahorra gran parte del trabajo porque en vez de instalar manualmente estas dos herramientas de las que hemos hablado anteriormente, lo automatizamos de tal manera que nos crea "**contenedores**". Dichos contenedores cuentan con estas herramientas de manera independiente.

Esto nos ahorra muchos quebraderos de cabeza, ya que configurando el archivo y sabiendo unos cuantos comandos en la terminal nos crea el entorno que queremos.

### Introducción Práctica 3 Parte 1

Vamos a proceder a explicar el `docker-compose` de la primera parte de la práctica 3. Voy a adjuntar el código entero del docker-compose y luego a desglosarlo parte por parte.

~~~
services:
  drupal:
    image: drupal:latest
    container_name: drupal-vs
    ports:
      - 81:80
    volumes:
      - volumenDrupal:/var/www/html/
    restart: always

  db:
    image: mysql:latest
    container_name: mysql-vs
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_USER: vs
      MYSQL_PASSWORD: vs
      MYSQL_DATABASE: parte1
    volumes:
      - volumenSQL:/var/lib/mysql
    restart: always
volumes:
  volumenDrupal:
  volumenSQL:
  ~~~

- Como podemos observar el archivo se divide en dos partes: la parte de servicios que vamos a usar y la de volúmenes que hemos declarado.

### Servicios (Parte 1)

Como se nos especifica en el enunciado vamos a usar en este caso dos servicios: `Drupal` y `MySQL`.

- Drupal:

    1. `image: drupal:latest` -> Indicamos que vamos a usar la última versión disponible de la imagen de Drupal en DH.
    2. `container_name: drupal-vs` -> Le damos nombre al contenedor que vamos a crear, en este caso: drupal-vs
    3. `ports:
      - 81:80` -> Mapea el puerto 81 del host al 80 del contenedor. Elegimos el 81 porque es el que se nos especifica en el enunciado.
    4. `volumes:
      - volumenDrupal:/var/www/html/` -> Crea un volumen llamado ***"volumenDrupal"*** en el host el cual vinculamos al directorio ***/var/ww/html*** dentro del contenedor, que es donde se almacena el código de Drupal. Esto lo hacemos para que la información persista dado a que, en el apartado 5 del enunciado se nos pide que se borre los contenedores para ver si la información se mantiene.
    5. `restart: always` -> Esta última línea indica que el contenedor se reiniciará en el caso de que haya algún fallo, o bien se detenga. Nos proporciona alta disponibilidad.

- MySQL:

    1. `image: mysql:latest` -> Seleccionamos el uso de la última versión disponible de la imagen de MySQL en DH.
    2. `container_name: mysql-vs` -> Creamos un nombre para el contenedor en este caso será "mysql-vs".
    3. `environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_USER: vs
      MYSQL_PASSWORD: vs
      MYSQL_DATABASE: parte1` -> En las variables del entorno declaramos creamos una contraseña root de MySQL la cual en este caso es: ***example***, un usuario y contraseña para dicho usuario en el que hemos asignado a ambas ***vs***, y por último el nombre que va tener la base de datos una vez se inicie el contenedor: ***parte1***.
    4. `volumes:
      - volumenSQL:/var/lib/mysql` -> Creamos un volumen llamado ***volumenSQL*** en el host, el cual está vinculado con el directorio de MySQL donde se almacenan los datos: ***/var/lib/mysql***, por la misma razón que explicamos antes en el apartado de **Drupal**.
    5. `restart: always` -> Mismo motivo que con el servicio de **Drupal**.

### Volumes (Parte 1)

~~~
volumes:
  volumenDrupal:
  volumenSQL:
  ~~~
Aquí declaramos los volúmenes que hemos usado tanto en **Drupal** como en **MySQL**, para que toda la información persista por lo que si eliminamos o detenemos los contenedores creados los datos se mantendrán.



##### Bibliografía
<https://code.visualstudio.com/docs/languages/markdown>
<https://hub.docker.com/_/drupal>
<https://hub.docker.com/_/mysql>