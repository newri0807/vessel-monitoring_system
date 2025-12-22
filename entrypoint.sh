# [Stage 1] 빌드 단계 (Maven으로 WAR 파일 생성)
FROM maven:3.8.6-openjdk-8 as builder
WORKDIR /app

# 프로젝트 설정 파일 복사
COPY pom.xml .

# 소스 코드 및 웹 리소스 복사
COPY src ./src
COPY WebContent ./WebContent

# 빌드 실행 (테스트 건너뛰고 빠르게)
RUN mvn package -DskipTests

# [Stage 2] 실행 단계 (Tomcat)
FROM tomcat:9-jdk8-openjdk

# 1. 기존 톰캣 앱 삭제 (ROOT 폴더 비우기)
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. 빌드 단계에서 만든 WAR 파일을 가져와서 실행
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# 톰캣 실행 명령어(catalina.sh run)를 바로 실행
EXPOSE 8080
CMD ["catalina.sh", "run"]
