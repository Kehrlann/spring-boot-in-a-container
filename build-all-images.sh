#!/usr/bin/env bash

docker build -t kehrlann/pet-clinic:ubuntu -f dockerfiles/1_ubuntu.dockerfile .
docker build -t kehrlann/pet-clinic:openjdk-8 -f dockerfiles/2_openjdk.dockerfile .
docker build -t kehrlann/pet-clinic:openjdk-8-alpine -f dockerfiles/3_openjdk-alpine.dockerfile .
