#!/usr/bin/env bash

# Start by building the app
pushd spring-petclinic
./mvnw clean package
popd

# Build the images
## Basic images
docker build -t kehrlann/pet-clinic:ubuntu -f dockerfiles/1_ubuntu.dockerfile .
docker build -t kehrlann/pet-clinic:openjdk-8 -f dockerfiles/2_openjdk.dockerfile .
docker build -t kehrlann/pet-clinic:openjdk-8-alpine -f dockerfiles/3_openjdk-alpine.dockerfile .
docker build -t kehrlann/pet-clinic:distroless -f dockerfiles/4_distroless.dockerfile .
source build-layers.sh
docker build -t kehrlann/pet-clinic:multistage -f dockerfiles/6_multistage.dockerfile .
DOCKER_BUILDKIT=1 docker build -t kehrlann/pet-clinic:multistage-cache -f dockerfiles/7_multistage-cache.dockerfile .

# cloud native images
pushd spring-petclinic
pack build kehrlann/pet-clinic:pack-cf-cn-buildpack --builder=cloudfoundry/cnb
pack build kehrlann/pet-clinic:pack-heroku-buildpack --builder=heroku/buildpacks
popd

# jib
pushd spring-petclinic
mvn jib:dockerBuild
popd
# mvn com.google.cloud.tools:jib-maven-plugin:build -Dimage=kehrlann/pet-clinic:jib
