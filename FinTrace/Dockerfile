# Use Tomcat 10.1 with JDK 17
FROM tomcat:10.1-jdk17

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your entire WebContent folder to ROOT
COPY WebContent /usr/local/tomcat/webapps/ROOT/

# Copy compiled classes to WEB-INF/classes
COPY build/classes /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/

# Copy all JARs to WEB-INF/lib
COPY WebContent/WEB-INF/lib /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
