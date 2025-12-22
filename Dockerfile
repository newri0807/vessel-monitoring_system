# [Stage 1] 빌드 단계
FROM maven:3.8.6-openjdk-8 as builder
WORKDIR /app

# 1. 설정 파일 복사
COPY pom.xml .

# 2. 소스 코드 복사
COPY src ./src
COPY WebContent ./WebContent

RUN mkdir -p src/main/webapp && cp -r WebContent/* src/main/webapp/

# 3. 빌드 실행
RUN mvn package -DskipTests

# [Stage 2] 실행 단계 (Tomcat)
FROM tomcat:9-jdk8-openjdk

# 기존 톰캣 앱 삭제
RUN rm -rf /usr/local/tomcat/webapps/*

# WAR 파일 복사
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
