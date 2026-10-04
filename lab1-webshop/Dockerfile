FROM tomcat:11.0.26-jdk25-temurin AS tomcat

FROM amazoncorretto:27

ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH="${CATALINA_HOME}/bin:${PATH}"

COPY --from=tomcat /usr/local/tomcat /usr/local/tomcat

WORKDIR /usr/local/tomcat

EXPOSE 8080

CMD ["catalina.sh", "run"]