FROM openjdk:8-jre-alpine

COPY spring-petclinic/target/spring-petclinic-*.jar /app.jar

ENTRYPOINT ["java","-jar","/app.jar"]
