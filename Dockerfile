FROM maven:3.8.4-openjdk-8 AS builder
WORKDIR /app

COPY pom.xml .
COPY src ./src

# 빌드 직전에 파일이 존재하는지 출력
RUN ls -l src/main/resources/resources/database.properties || echo "파일이 없습니다!"

RUN mvn clean package -DskipTests

FROM tomcat:9.0-jdk8-openjdk-slim
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
