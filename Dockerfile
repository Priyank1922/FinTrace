FROM eclipse-temurin:17-jdk-focal AS builder
WORKDIR /app

# Copy complete FinTrace folder
COPY FinTrace/ .

RUN chmod +x gradlew
RUN ./gradlew bootJar -x test

FROM eclipse-temurin:17-jre-focal
WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.jar"]
