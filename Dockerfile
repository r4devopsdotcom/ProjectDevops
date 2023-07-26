FROM openjdk:11-jdk-slim-buster

RUN addgroup --system devopsc && adduser --ingroup devopsc javams

USER javams:devopsc

ENV JAVA_OPTS=""

ADD target/devops-0.0.1-SNAPSHOT.jar app.jar

VOLUME /tmp

EXPOSE 9090

ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ] 
