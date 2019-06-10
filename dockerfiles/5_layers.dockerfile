FROM gcr.io/distroless/java

ARG DEPENDENCY=spring-petclinic/target/dependency

COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app

ENTRYPOINT ["java","-cp","app:app/lib/*", "org.springframework.samples.petclinic.PetClinicApplication"]
