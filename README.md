# Spring Boot in a Container

How to containerize Spring Boot, the presentation. This presentation is heavily based on
the Spring Topical guide [here](https://spring.io/guides/topicals/spring-boot-docker/).

## Setup

You will need to install:

- Docker: https://docs.docker.com/install/
- The `pack` CLI for cloud-native buildpacks: https://buildpacks.io/docs/install-pack/

## Build the images

⚠ If you run the entire build script, it might take a very long time, as will download
gigabytes of base images and build images. If you just want to experiment, you can take
the dockerfiles one by one and build them. Or just run the `pack` command, etc.

To build all images, run:

```bash
  $ ./build-all-images.sh
```

## Inspecting build images

To inspect built images and take a look at the layers produced, I highly recommend
[dive](https://github.com/wagoodman/dive). Try it out, it's awesome !
