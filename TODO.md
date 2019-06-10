# TODO

## Required

[x] Ubuntu base image
[x] Openjdk
[x] Openjdk-alpine
[x] Distroless
[x] Organize layers
[ ] Jib

## Potentially

[x] Multi-stage build, no cache
  - without caching, takes about 5 to 10 minutes, depending on the network speed
[x] Multi-stage build, with cache
  - With caching (but doing a "clean package" rather than just "install"), takes 10 to 15 seconds.
[ ] Cloud native buildpacks
