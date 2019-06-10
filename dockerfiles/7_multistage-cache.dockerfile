# syntax=docker/dockerfile:experimental
# BUILD SOURCE
FROM openjdk:8-jdk-alpine as build
WORKDIR /workspace/spring-petclinic/

COPY spring-petclinic/mvnw .
COPY spring-petclinic/.mvn .mvn
COPY spring-petclinic/pom.xml .
COPY spring-petclinic/src src

RUN --mount=type=cache,target=/root/.m2 ./mvnw clean package -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# BUILD IMAGE
FROM gcr.io/distroless/java

ARG DEPENDENCY=/workspace/spring-petclinic/target/dependency

COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

ENTRYPOINT ["java","-cp","app:app/lib/*", "org.springframework.samples.petclinic.PetClinicApplication"]
