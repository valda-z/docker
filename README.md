# docker workshop

This repository contains example application for our docker experiments.

## prerequisites

Your development machine linux/osx/windows has installed these tools:

* docker
    * linux:
        * https://docs.docker.com/install/linux/docker-ce/ubuntu/
        * https://docs.docker.com/install/linux/docker-ce/debian/
        * https://docs.docker.com/install/linux/docker-ce/centos/
    * windows: https://docs.docker.com/docker-for-windows/install/
    * osx: https://docs.docker.com/docker-for-mac/install/
* docker-compose: https://docs.docker.com/compose/install/
* git: https://git-scm.com/downloads
* az cli (azure tools): https://docs.microsoft.com/fi-FI/cli/azure/install-azure-cli?view=azure-cli-latest

## check docker

Docker build files are stored in project folders myappspa and myapptodo.
Myappspa - single page application which runs in nginx (angular based application), myapptodo is Java spring-boot application which offers REST API for single page app, data are stored in postgres.

### Dockerfile for myappspa

Dockerfile is derived from nginx image, to the docker image we will include finally our pages and startup shell script.

```dockerfile
FROM kyma/docker-nginx
COPY src/ /var/www
COPY startup.sh /startup.sh
ENTRYPOINT [ "/bin/bash", "/startup.sh" ]
```

### Dockerfile for myapptodo

Dockerfile for java based app contains two base layers (one for build and one for final image with application). During image building we well build final jar file from source codes (in build layer) and finally we will copy jar file to final image - it ensures that final image will be small as posible.

```dockerfile
### BASE image
FROM openjdk:8-jdk-alpine AS base
VOLUME /tmp
EXPOSE 8080
ENV APP_HOME /app
RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/config

### BUILD image
FROM openjdk:8-jdk-alpine AS build
# Install Maven
RUN apk add --no-cache curl tar bash
ARG MAVEN_VERSION=3.3.9
ARG USER_HOME_DIR="/root"
RUN mkdir -p /usr/share/maven && \
curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
# speed up Maven JVM a bit
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
ENTRYPOINT ["/usr/bin/mvn"]
# ----
# Install project dependencies and keep sources
# make source folder
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# install maven dependency packages (keep in image)
COPY pom.xml /usr/src/app
COPY src /usr/src/app/src
# Build my applicatio
RUN mvn clean package

### CREATE final image
FROM base as final
WORKDIR $APP_HOME
COPY --from=build /usr/src/app/target/app.jar .
# certificate for postgres
# RUN mkdir /root/.postgresql
# COPY src/main/postgresql/root.crt /root/.postgresql/
# run it ...
ENTRYPOINT [ "java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar" ]
```

### build and test myappspa

We can build images one by one from command line lets try it for myappspa:

```bash
# grab source codes first
git pull https://github.com/valda-z/docker.git

cd ./docker

# build myappspa from commandline
cd myappspa
docker build -t myappspa .

# test it
docker run -p 8080:80 myappspa
```

Now you can test it in browser http://localhost:8080

### build and test whole solution

Now lets use docker compose for build, we will use this compose file:

```yaml
version: '3'
services:
  db:
    image: postgres:11-alpine
    environment:
      POSTGRES_PASSWORD: examplepwd
      POSTGRES_USER: exampleusr
      POSTGRES_DB: todo
  myappspa:
    build: ./myappspa
    image: ${ACR_URL}/myappspa:1
    ports: 
      - "8080:80"
    environment: 
      TODOAPIPROTOCOL: "http"
      TODOAPISERVER: "localhost"
      TODOAPIPORT: "8081"
  myapptodo:
    build: ./myapptodo
    image: ${ACR_URL}/myapptodo:1
    depends_on:
       - db
    ports: 
      - "8081:8080"
    environment: 
      POSTGRESQL_URL: "jdbc:postgresql://db:5432/todo?user=exampleusr&password=examplepwd"
```

```bash
# build all images
cd ./docker
export ACR_URL=test
docker-compose build

# and now lets run it
docker-compose up
```

Now you can test it in browser http://localhost:8080

## try it with private container registry

We will use Azure container registry for our images, lets deploy ACR and push images there ..

```bash
# variables
export RESOURCE_GROUP=QTEST
export LOCATION="northeurope"
export ACR_NAME=valdaakssec001

# create resource group
az group create --location ${LOCATION} --name ${RESOURCE_GROUP}

# create ACR
az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Standard --location ${LOCATION}

# Get ACR_URL for future use with docker-compose and build
export ACR_URL=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)
echo $ACR_URL

# login to registry
az acr login --name $ACR_NAME

# build and push
docker-compose build
docker-compose push
```
