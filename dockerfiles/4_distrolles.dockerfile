FROM gcr.io/distroless/java

COPY spring-petclinic/target/spring-petclinic-*.jar /app.jar

CMD ["/app.jar"]
