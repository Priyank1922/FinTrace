FROM tomcat:10.1-jdk21

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file
COPY FinTrace/FinTrace.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
