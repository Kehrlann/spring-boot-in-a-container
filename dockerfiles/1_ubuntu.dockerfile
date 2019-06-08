FROM ubuntu:latest

RUN apt update && apt install openjdk-8-jre -y

COPY spring-petclinic/target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar /app.jar

ENTRYPOINT ["java","-jar","/app.jar"]
