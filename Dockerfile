# 1. 빌드 스테이지
FROM maven:3.8.4-openjdk-8 AS builder
WORKDIR /app

# 2. 소스 복사 (이미 deploy.yml에서 구조를 다 맞춰놓음)
COPY pom.xml .
COPY src ./src

# 3. 빌드 실행 (구조가 src/main/... 이므로 바로 빌드 가능)
RUN mvn clean package -DskipTests

# 4. 실행 스테이지
FROM tomcat:9.0-jdk8-openjdk-slim
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
