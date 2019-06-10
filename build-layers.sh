#!/usr/bin/env bash

DEPS_FOLDER=$PWD/spring-petclinic/target/dependency
mkdir -p "$DEPS_FOLDER"
pushd "$DEPS_FOLDER"
jar -xf ../*.jar
popd

docker build -t kehrlann/pet-clinic:optimized-layers -f dockerfiles/5_layers.dockerfile .
