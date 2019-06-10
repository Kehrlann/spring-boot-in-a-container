# TODO

## Required

[x] Ubuntu base image
[x] Openjdk
[x] Openjdk-alpine
[x] Distroless
[x] Organize layers
[x] Jib

## Potentially

[x] Multi-stage build, no cache
  - without caching, takes about 5 to 10 minutes, depending on the network speed
[x] Multi-stage build, with cache
  - With caching (but doing a "clean package" rather than just "install"), takes 10 to 15 seconds.
[x] Cloud native buildpacks
  - First start is very long: get the builder image, get Java, build (without dependencies)
  - Second run about 30s, both heroku and CF CN
