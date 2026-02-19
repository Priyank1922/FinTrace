FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17
WORKDIR /usr/local/tomcat
COPY --from=build /app/target/FinTrace.war webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
