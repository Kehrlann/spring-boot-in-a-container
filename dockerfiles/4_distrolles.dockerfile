FROM gcr.io/distroless/java

COPY spring-petclinic/target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar /app.jar

CMD ["/app.jar"]
